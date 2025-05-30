# frozen_string_literal: true

require 'uri'
require_relative '../../workflow'
require_relative '../../../helpers/string_utils'
require_relative '../../../helpers/utils'
require_relative '../../../models/step'

# builds the Create Allocation workflow
class CreateAllocations < Workflow
  def unbuilt_steps
    [
      lookup_subscription_step,
      create_allocation_step
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

  def create_allocation_step
    {
      name: 'create allocation',
      required: true,
      method: :post,
      url: lambda { |row, config|
        "#{config.base_url}/subscriptions/#{row['subscription id']}/components/#{component(row)}/allocations.json"
      },
      json: lambda { |row|
        payload = {
          allocation: {
            quantity: row['quantity'],
            price_point_id: price_point(row),
            memo: row['memo']
          }
        }
        trim_payload(payload)
      },
      response_key: 'allocation id',
      response_val: ->(result) { result['allocation']['id'] },
      response_text: lambda { |result, _config|
        "allocation created for subscription #{result&.dig('allocation', 'subscription_id')}"
      }
    }
  end
end

def price_point(row)
  if present?(row['component price point id'])
    row['component price point id'].to_i
  else
    row['component price point handle']
  end
end

def component(row)
  if present?(row['component id'])
    row['component id']
  else
    "handle:#{URI.encode_www_form_component(row['component handle'])}"
  end
end
