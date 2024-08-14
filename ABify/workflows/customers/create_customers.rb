# frozen_string_literal: true

require 'uri'
require_relative '../workflow'
require_relative '../../helpers/string_utils'
require_relative '../../helpers/utils'
require_relative '../../models/step'

# builds the Create Customers workflow
class CreateCustomers < Workflow
  def unbuilt_steps
    [
      {
        name: 'lookup parent customer',
        required: true,
        skip: lambda { |row|
                false?(row['has parent']) || (true?(row['has parent']) && !blank?(row['parent customer id']))
              },
        url: lambda { |row, config|
               parent_reference = URI.encode_www_form_component(row['parent reference'])
               "#{config.base_url}/customers/lookup.json?reference=#{parent_reference}"
             },
        method: :get,
        response_key: 'parent customer id',
        response_val: ->(result) { result['customer']['id'] }
      },
      {
        name: 'create customer',
        required: true,
        method: :post,
        url: ->(_row, config) { "#{config.base_url}/customers.json" },
        json: Payloads::Customers.method(:create_customers),
        response_key: 'customer id',
        response_val: ->(result) { result['customer']['id'] },
        response_text: ->(result, config) { "#{config.base_url}/customers/#{result['customer']['id']}" }
      },
      {
        name: 'create payment profile',
        required: true,
        skip: ->(row) { false?(row['create payment profile']) },
        url: ->(_row, config) { "#{config.base_url}/payment_profiles.json" },
        method: :post,
        json: Payloads::PaymentProfiles.method(:create_payment_profiles),
        response_key: 'payment_profile_id',
        response_val: ->(result) { result['payment_profile']['id'] },
        response_text: lambda { |result, config|
                         customer_id = result['payment_profile']['customer_id']
                         payment_profile_id = result['payment_profile']['id']
                         "#{config.base_url}/customers/#{customer_id}/payment_profiles?id=#{payment_profile_id}"
                       }
      }
    ]
  end
end
