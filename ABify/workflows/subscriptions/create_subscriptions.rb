# frozen_string_literal: true

require_relative '../workflow'
require_relative '../../helpers/string_utils'
require_relative '../../helpers/utils'
require_relative '../../models/step'

# builds the Create Subscriptions workflow
class CreateSubscriptions < Workflow
  def unbuilt_steps
    [
      {
        name: 'lookup customer',
        required: true,
        skip: ->(row) { present?(row['customer id']) },
        method: :get,
        url: ->(row, config) { "#{config.base_url}/customers/lookup.json?reference=#{row['customer reference']}" },
        response_key: 'customer id',
        response_val: ->(result) { result['customer']['id'] }
      },
      {
        name: 'lookup payment profile',
        required: true,
        skip: ->(row) { present?(row['payment profile id']) },
        method: :get,
        url: ->(row, config) { "#{config.base_url}/payment_profiles.json?customer_id=#{row['customer id']}" },
        response_key: 'payment profile id',
        response_val: ->(result) { result.last['payment_profile']['id'] }
      },
      {
        name: 'create subscription',
        required: true,
        method: :post,
        url: ->(_row, config) { "#{config.base_url}/subscriptions.json" },
        json: Payloads::Subscriptions.method(:create_subscriptions),
        response_key: 'subscription id',
        response_val: ->(result) { result['subscription']['id'] },
        response_text: ->(result, config) { "#{config.base_url}/subscriptions/#{result['subscription']['id']}" }
      }
    ]
  end
end
