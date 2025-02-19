# frozen_string_literal: true

require 'typhoeus'
require_relative '../spec_helper'
require_relative '../../models/step_callback_handler'

RSpec.describe StepCallbackHandler do
  let(:step) do
    double(
      'Step',
      name: 'test-step',
      required: true,
      response_key: 'test step',
      response_val: ->(res) { res['new_id'] },
      response_text: ->(res, _) { res['new_id'] },
      json: nil
    )
  end
  let(:row) { double('Row', data: {}, index: 1, requests: [], errors: [], responses: []) }
  let(:next_steps) { [double('Step')] }
  let(:hydra) { double('Hydra') }
  let(:logger) { double('Logger') }
  let(:config) { double('Config', logger: logger, row_count: 10, base_url: 'www') }
  let(:request) do
    double(
      'Request',
      base_url: 'www',
      options: { method: 'GET' },
      body: nil
    )
  end
  let(:response) { Typhoeus::Response.new(code: 200, return_code: :ok, body: '{"new_id": "111"}') }

  before do
    allow(next_steps.first).to receive(:enqueue)
    allow(response).to receive(:request).and_return(request)
    allow(logger).to receive(:log_response)
    allow(row).to receive(:status=) { |value| allow(row).to receive(:status).and_return(value) }
    allow(row).to receive(:status) { |value| allow(row).to receive(:status).and_return(value) }
  end

  subject { described_class.new(step, row, next_steps, hydra, config) }

  describe '#handle_response' do
    context 'when response is successful' do
      it 'processes success and queues next step' do
        subject.handle_response(response)

        expect(row.data['test step']).to eq('111')
        expect(row.responses.first).to include(step: 'test-step', text: '111', key: 'test step', value: '111')
        expect(next_steps.first).to have_received(:enqueue)
      end
    end

    context 'when step is required and response is an error' do
      let(:error_response) { Typhoeus::Response.new(code: 422, return_code: :ok, body: '{"errors": "Sorry Charlie"}') }

      before { allow(error_response).to receive(:request).and_return(request) }

      it 'processes error but does not queue next step' do
        subject.handle_response(error_response)

        expect(row.status).to eq('error')
        expect(row.errors).to include(hash_including(step: 'test-step', text: 'Sorry Charlie', code: 422))
        expect(next_steps.first).not_to have_received(:enqueue)
      end
    end

    context 'when step is not required and response is an error' do
      let(:error_response) { Typhoeus::Response.new(code: 422, return_code: :ok, body: '{"errors": "Not today Jay"}') }

      before do
        allow(step).to receive(:required).and_return(false)
        allow(error_response).to receive(:request).and_return(request)
      end

      it 'processes error and queues next step' do
        subject.handle_response(error_response)

        expect(row.status).not_to eq('error')
        expect(row.errors).to include(hash_including(step: 'test-step', text: 'Not today Jay', code: 422))
        expect(next_steps.first).to have_received(:enqueue)
      end
    end
  end

  describe '#queue_next_step' do
    it 'marks row complete if there are no next steps' do
      handler = described_class.new(step, row, [], hydra, config)
      handler.queue_next_step

      expect(row.status).to eq('complete')
    end
  end
end
