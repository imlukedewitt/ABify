# frozen_string_literal: true

require 'spec_helper'
require 'typhoeus'
require_relative '../../models/importer'

RSpec.describe Importer do
  let(:config) do
    double('Config', row_count: 10, keystore: keystore, subdomain: 'test', domain: 'example.com', rows: [row])
  end
  let(:keystore) { double('Keystore', set: nil) }
  let(:workflow) { double('Workflow', steps: [step]) }
  let(:data) { double('JsonData', rows: [row], completed_row_count: 1, failed_row_count: 0, summary: {}) }
  let(:row) { double('Row') }
  let(:step) { double('Step', config: config) }
  let(:hydra) { instance_double(Typhoeus::Hydra, run: true) }
  let(:csv_writer) { instance_double(CSVWriter, write_import_results: nil) }
  let(:logger) { instance_double(HydraLogger) }
  let(:buffer_step) { instance_double(BufferStep, enqueue: nil) }

  before do
    allow(Typhoeus::Hydra).to receive(:new).and_return(hydra)
    allow(CSVWriter).to receive(:new).and_return(csv_writer)
    allow(HydraLogger).to receive(:new).and_return(logger)
    allow(config).to receive(:row_count=)
    allow(config).to receive(:id=)
    allow(config).to receive(:logger=)
    allow(step).to receive(:config=)
    allow(row).to receive(:data).and_return({})
    allow(row).to receive(:index).and_return(1)
    allow(row).to receive(:status).and_return(nil)
    allow(BufferStep).to receive(:new).and_return(buffer_step)
    allow(buffer_step).to receive(:enqueue)
    allow($stdout).to receive(:write) # suppress 'puts' output
  end

  subject { Importer.new(config, workflow, data) }

  describe '#start' do
    it 'runs the import process' do
      expect(subject.status).to eq('not started')
      subject.start

      expect(keystore).to have_received(:set).with(subject.id, subject.summary)
      expect(hydra).to have_received(:run)
      expect(csv_writer).to have_received(:write_import_results)
      expect(subject.status).to eq('complete')
    end
  end

  describe '#summary' do
    it 'returns a summary of the import process' do
      subject.start

      summary = subject.summary

      expected_summary = {
        id: subject.id,
        status: 'complete',
        created_at: instance_of(Time),
        completed_at: instance_of(Time),
        run_time: kind_of(String),
        row_count: config.row_count,
        completed_rows: data.completed_row_count,
        failed_rows: data.failed_row_count,
        subdomain: config.subdomain,
        domain: config.domain,
        data: data.summary(data: true)
      }

      expect(summary).to include(expected_summary)
    end
  end
end
