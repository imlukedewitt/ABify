# frozen_string_literal: true

require 'spec_helper'
require_relative '../../models/buffer_step'

RSpec.describe BufferStep do
  let(:keystore) { double('Keystore') }
  let(:config) { double('Config', keystore: keystore, id: '123') }

  subject { described_class.new(config) }

  it 'initializes with a config' do
    expect(subject.instance_variable_get(:@keystore)).to eq(keystore)
    expect(subject.instance_variable_get(:@id)).to eq('123')
  end
end
