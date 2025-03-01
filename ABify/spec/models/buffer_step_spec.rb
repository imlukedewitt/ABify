# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../models/buffer_step'

RSpec.describe BufferStep do
  let(:keystore) { double('Keystore') }
  let(:config) { double('Config', keystore: keystore, id: '123') }
  let(:hydra) { Typhoeus::Hydra.new }
  let(:steps) { [double('Step')] }
  let(:row) { double('Row') }

  subject { described_class.new(config) }

  before do
    response = Typhoeus::Response.new(code: 200, return_code: :ok, body: 'OK')
    Typhoeus.stub(/.*/).and_return(response)
  end

  describe '#initialize' do
    it 'initializes with a config' do
      expect(subject.instance_variable_get(:@keystore)).to eq(keystore)
      expect(subject.instance_variable_get(:@id)).to eq('123')
    end
  end

  describe '#enqueue' do
    before do
      allow(steps.first).to receive(:enqueue)
    end

    context 'when keep_running is true' do
      before { allow(subject).to receive(:keep_running).and_return(true) }

      it 'queues the next step upon completion' do
        subject.enqueue(row, hydra, steps)
        hydra.run

        expect(steps.first).to have_received(:enqueue).with(row, hydra, [])
      end
    end

    context 'when keep_running is false' do
      before { allow(subject).to receive(:keep_running).and_return(false) }

      it 'does not enqueue the step' do
        subject.enqueue(row, hydra, steps)
        hydra.run

        expect(steps.first).not_to have_received(:enqueue)
      end
    end
  end
end
