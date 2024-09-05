# frozen_string_literal: true

require 'spec_helper'
require_relative '../../payloads/customers'

RSpec.describe Payloads::Customers do
  include FactoryBot::Syntax::Methods

  describe '.create_customers' do
    it 'generates a Create Customers payload' do
      row_data = FactoryBot.build(:create_customer_row)
      payload = Payloads::Customers.create_customers(row_data)

      expect(payload).to be_a(Hash)
      expect(payload[:customer]).to be_a(Hash)
      expect(payload[:customer][:first_name]).to eq(row_data['first name'])
      expect(payload[:customer][:last_name]).to eq(row_data['last name'])
      expect(payload[:customer][:email]).to eq(row_data['email'])
      expect(payload[:customer][:cc_emails]).to eq(row_data['cc emails'])
      expect(payload[:customer][:phone]).to eq(row_data['phone'])
      expect(payload[:customer][:address]).to eq(row_data['shipping address'])
      expect(payload[:customer][:address_2]).to eq(row_data['shipping address 2'])
      expect(payload[:customer][:city]).to eq(row_data['shipping city'])
      expect(payload[:customer][:state]).to eq(row_data['shipping state'])
      expect(payload[:customer][:country]).to eq(row_data['shipping country'])
      expect(payload[:customer][:zip]).to eq(row_data['shipping zip'])
      expect(payload[:customer][:tax_exempt]).to eq(row_data['tax exempt'])
      expect(payload[:customer][:vat_number]).to eq(row_data['vat number'])
      expect(payload[:customer][:verified]).to eq(row_data['verified'])
      expect(payload[:customer][:metafields]).to include('field1' => row_data['custom field [field1]'])
      expect(payload[:customer][:metafields]).to include('field2' => row_data['custom field [field2]'])
    end
  end
end
