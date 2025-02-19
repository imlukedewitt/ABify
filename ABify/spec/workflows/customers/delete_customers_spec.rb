# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../workflows/customers/delete_customers'

RSpec.describe DeleteCustomers do
  let(:config) { double('Config', base_url: '') }
  let(:workflow) { DeleteCustomers.new }

  describe '#unbuilt_steps' do
    it 'returns an array of unbuilt steps' do
      steps = workflow.unbuilt_steps
      expect(steps).to be_an(Array)
      expect(steps.size).to eq(2)
    end
  end

  describe 'Customer lookup step' do
    let(:step) { workflow.steps[0] }
    let(:row) { { 'customer reference' => 'cus_123' } }

    it 'generates the correct URL' do
      url = step.url.call(row, config)
      expect(url).to eq('/customers/lookup.json?reference=cus_123')
    end

    it 'uses the corrent method' do
      expect(step.method).to eq(:get)
    end

    it 'skips the step if customer id is present' do
      expect(step.skip.call(row)).to be(false)
      row['customer id'] = '123'
      expect(step.skip.call(row)).to be(true)
    end

    it 'extracts the customer id from the response' do
      response = { 'customer' => { 'id' => '123' } }
      expect(step.response_val.call(response)).to eq('123')
    end

    it 'returns the correct response key' do
      expect(step.response_key).to eq('customer id')
    end
  end

  describe 'Delete customer step' do
    let(:step) { workflow.steps[1] }
    let(:row) { { 'customer id' => '123' } }

    it 'generates the correct URL' do
      url = step.url.call(row, config)
      expect(url).to eq('/customers/123.json')
    end

    it 'uses the corrent method' do
      expect(step.method).to eq(:delete)
    end
  end
end
