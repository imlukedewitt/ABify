# frozen_string_literal: true

require 'uri'
require_relative '../../workflow'
require_relative '../../../helpers/string_utils'
require_relative '../../../helpers/utils'
require_relative '../../../models/step'

# builds the Create Metered Usage workflow
class CreateMeteredUsage < Workflow
  def unbuilt_steps
    [
      lookup_subscription_step,
      lookup_component_price_point_by_handle_step,
      create_metered_usage_step
    ]
  end

  private

  def lookup_subscription_step
    {
      name: 'lookup subscription by reference',
      required: true,
      skip: ->(row) { present?(row['subscription id']) },
      url: lambda { |row, config|
        subscription_reference = URI.encode_www_form_component(row['subscription reference'])
        "#{config.base_url}/subscriptions/lookup.json?reference=#{subscription_reference}"
      },
      method: :get,
      response_key: 'subscription id',
      response_val: ->(result) { result.dig('subscription', 'id') }
    }
  end

  def lookup_component_price_point_by_handle_step
    {
      name: 'lookup component price point by handle',
      required: true,
      skip: ->(row) { present?(row['component price point id']) || blank?(row['component price point handle']) },
      url: lambda { |row, config|
        price_point_handle = URI.encode_www_form_component(row['component price point handle'])
        "#{config.base_url}/components/#{component_identifier(row)}/price_points/handle:#{price_point_handle}.json"
      },
      method: :get,
      response_key: 'component price point id',
      response_val: ->(result) { result.dig('price_point', 'id') }
    }
  end

  def create_metered_usage_step
    extend Utils
    {
      name: 'create metered usage',
      required: true,
      method: :post,
      url: lambda { |row, config|
        "#{config.base_url}/subscriptions/#{row['subscription id']}/components/#{component_identifier(row)}/usages.json"
      },
      json: lambda { |row|
        payload = {
          usage: {
            quantity: row['quantity'],
            price_point_id: row['component price point id'],
            memo: row['memo']
          }
        }
        trim_payload(payload)
      },
      response_text: lambda { |result, _config|
        "metered usage created for subscription #{result.dig('usage', 'subscription_id')}"
      },
      response_key: 'metered usage id',
      response_val: ->(result) { result&.dig('usage', 'id') }
    }
  end
end

def component_identifier(row)
  if present?(row['component id'])
    row['component id']
  else
    "handle:#{URI.encode_www_form_component(row['component handle'])}"
  end
end
