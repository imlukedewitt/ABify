# frozen_string_literal: true

require 'spec_helper'
require_relative '../../models/step'

RSpec.describe Step do
  let(:config) { double('Config', api_key: '123') }

  subject do
    described_class.new(
      name: 'test-step',
      required: true,
      url: ->(_, _) { 'http://example.com/customers/123' },
      method: :get,
      response_key: 'test step'
    )
  end

  before do
    subject.config = config
    response = Typhoeus::Response.new(code: 200, return_code: :ok, body: 'OK')
    Typhoeus.stub(/.*/).and_return(response)
    allow_any_instance_of(StepCallbackHandler).to receive(:queue_next_step)
    allow_any_instance_of(StepCallbackHandler).to receive(:handle_response)
  end

  describe '#initialize' do
    it 'initializes with the correct attributes' do
      expect(subject.name).to eq('test-step')
      expect(subject.required).to eq(true)
      expect(subject.url.call(nil, nil)).to eq('http://example.com/customers/123')
      expect(subject.method).to eq(:get)
      expect(subject.response_key).to eq('test step')
    end
  end
end
