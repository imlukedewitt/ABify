# frozen_string_literal: true

require 'uri'
require_relative '../workflow'
require_relative '../../helpers/string_utils'
require_relative '../../helpers/utils'
require_relative '../../models/step'

# builds the Delete Customers workflow
class DeleteCustomers < Workflow
  def unbuilt_steps
    [
      lookup_customer_step,
      delete_customer_step
    ]
  end

  private

  def lookup_customer_step
    {
      name: 'lookup customer by reference',
      required: true,
      skip: ->(row) { present?(row['customer id']) },
      url:
        lambda { |row, config|
          customer_reference = URI.encode_www_form_component(row['customer reference'])
          "#{config.base_url}/customers/lookup.json?reference=#{customer_reference}"
        },
      method: :get,
      response_key: 'customer id',
      response_val: ->(result) { result['customer']['id'] }
    }
  end

  def delete_customer_step
    {
      name: 'delete customer',
      required: true,
      method: :delete,
      url: ->(row, config) { "#{config.base_url}/customers/#{row['customer id']}.json" },
      response_key: 'customer id',
      response_val: ->(result) { result },
      response_text: ->(_result, _config) { 'customer deleted' }
    }
  end
end
