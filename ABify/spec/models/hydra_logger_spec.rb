# frozen_string_literal: true

require 'spec_helper'
require 'logger'
require_relative '../../models/hydra_logger'

RSpec.describe HydraLogger do
  let(:import_id) { 'test-import' }
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:response) do
    double('Response', success?: false, code: 422, status_message: 'Error', body: 'Error', request: request)
  end
  let(:request) { double('Request', options: { method: :get, body: 'body content' }, base_url: 'http://example.com') }
  let(:row_idx) { 5 }
  let(:row_count) { 10 }
  let(:step_name) { 'test_step' }

  before do
    allow(Logger).to receive(:new).and_return(logger)
    allow($stdout).to receive(:write) # suppress console output
  end

  subject { HydraLogger.new(import_id) }

  describe '#log_response' do
    it 'logs unsuccessful response details' do
      subject.log_response(response, row_idx, row_count, step_name)

      expect(logger).to have_received(:error).with(a_string_including("Row #{row_idx}, step: #{step_name}"))
      expect(logger).not_to have_received(:info)
    end

    it 'logs successful response details' do
      response = double('Response', success?: true, code: 200, status_message: 'OK', body: 'OK', request: request)

      subject.log_response(response, row_idx, row_count, step_name)

      expect(logger).to have_received(:info).with(a_string_including("Row #{row_idx}, step: #{step_name}"))
      expect(logger).not_to have_received(:error)
    end

    it 'increments error count for unsuccessful responses' do
      subject.log_response(response, row_idx, row_count, 'test_step')

      expect(subject.instance_variable_get(:@errors)).to eq(1)
    end

    it 'updates max_row_idx correctly' do
      subject.log_response(response, row_idx, row_count, 'test_step')

      expect(subject.instance_variable_get(:@max_row_idx)).to eq(row_idx)
    end

    it 'logs to console when not running on server' do
      allow(ENV).to receive(:[]).with('RUNNING_ON_SERVER').and_return(nil)

      expect { subject.log_response(response, row_idx, row_count, step_name) }
        .to output(%r{Processed rows: 05/10 Errors: 01/10}).to_stdout
    end

    it 'does not log to console when running on server' do
      allow(ENV).to receive(:[]).with('RUNNING_ON_SERVER').and_return('true')

      expect { subject.log_response(response, row_idx, row_count, step_name) }.not_to output.to_stdout
    end
  end
end
