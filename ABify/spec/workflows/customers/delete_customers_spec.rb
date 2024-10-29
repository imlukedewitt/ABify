# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../workflows/customers/delete_customers'

RSpec.describe DeleteCustomers do
  let(:config) { double('Config', base_url: '') }
  let(:workflow) { DeleteCustomers.new }
  let(:row) { { 'customer reference' => '123' } }

  describe '#unbuilt_steps' do
    it 'returns an array of unbuilt steps' do
      steps = workflow.unbuilt_steps
      expect(steps).to be_an(Array)
      expect(steps.size).to eq(2)
    end
  end

  describe 'lookup_customer_step' do
    let(:step) { lookup_customer_step }

    it 'generates the correct URL' do
      url = step[:url].call(row, config)
      expect(url).to eq('/customers/lookup.json?reference=123')
    end
  end
end
