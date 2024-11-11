# frozen_string_literal: true

require 'spec_helper'
require 'pry'
require_relative '../../models/step'

RSpec.describe Step do
  let(:config) { double('Config', api_key: '123') }
  let(:row_data) { { customer_id: '456' } }
  let(:row) { double('Row', data: row_data) }
  let(:hydra) { Typhoeus::Hydra.new }
  let(:next_steps) { [double('Step')] }
  let(:callback_handler) { instance_double(StepCallbackHandler) }

  subject do
    described_class.new(
      name: 'test-step',
      required: true,
      url: ->(row, _) { "http://example.com/customers/#{row[:customer_id]}" },
      method: :get,
      response_key: 'test step'
    )
  end

  before do
    subject.config = config
    response = Typhoeus::Response.new(code: 200, return_code: :ok, body: 'OK')
    Typhoeus.stub(/.*/).and_return(response)
    allow(StepCallbackHandler).to receive(:new).and_return(callback_handler)
    allow(callback_handler).to receive(:queue_next_step)
    allow(callback_handler).to receive(:handle_response)
  end

  describe '#enqueue' do
    context 'when skip condition is nil' do
      it 'queues the request with row data and handles the response' do
        subject.enqueue(row, hydra, next_steps)

        queued_request = hydra.queued_requests.first
        expect(queued_request).not_to be_nil
        expect(queued_request.url).to eq('http://example.com/customers/456')
        expect(queued_request.options[:method]).to eq(:get)
        expect(queued_request.options[:headers]).to include('Content-Type' => 'application/json')
        expect(queued_request.options[:userpwd]).to eq('123:x')
      end
    end

    context 'when there is a valid json body' do
      before { subject.instance_variable_set(:@json, ->(row) { { id: row[:customer_id] } }) }

      it 'queues the request with json body' do
        subject.enqueue(row, hydra, next_steps)

        queued_request = hydra.queued_requests.first
        expect(queued_request.options[:body]).to eq('{"id":"456"}')
      end
    end

    context 'when skip condition is false' do
      before { subject.instance_variable_set(:@skip, ->(_) { false }) }
      it 'queues the request and handles the response' do
        subject.enqueue(row, hydra, next_steps)
        hydra.run

        expect(callback_handler).to have_received(:handle_response)
      end
    end

    context 'when skip condition is true' do
      before { subject.instance_variable_set(:@skip, ->(_) { true }) }

      it 'skips the step and queues next step' do
        subject.enqueue(row, hydra, next_steps)

        expect(callback_handler).to have_received(:queue_next_step)
        expect(callback_handler).not_to have_received(:handle_response)
      end
    end
  end
end
