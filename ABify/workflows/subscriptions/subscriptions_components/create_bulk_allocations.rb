# frozen_string_literal: true

require 'uri'
require_relative '../../workflow'
require_relative '../../../helpers/string_utils'
require_relative '../../../helpers/utils'
require_relative '../../../models/step'

# builds the Create Bulk Allocations workflow
class CreateBulkAllocations < Workflow
  def unbuilt_steps
    [
      lookup_subscription_step,
      create_bulk_allocations_step
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

  def create_bulk_allocations_step
    {
      name: 'create bulk allocations',
      required: true,
      method: :post,
      url: lambda { |row, config|
        "#{config.base_url}/subscriptions/#{row['subscription id']}/allocations.json"
      },
      json: lambda { |row|
        trim_payload({ allocations: extract_allocations(row) })
      },
      response_key: 'allocation ids',
      response_val: ->(result) { result&.map { |item| item.dig('allocation', 'id') } },
      response_text: lambda { |result, _config|
        count = result&.size || 0
        subscription_id = result&.first&.dig('allocation', 'subscription_id')
        "#{count} allocations created for subscription #{subscription_id}"
      }
    }
  end

  def extract_allocations(row)
    allocations = []
    index = 1

    # Keep extracting allocations as long as we find component handles
    while present?(row["component handle #{index}"]) || present?(row["component id #{index}"])
      allocation = {
        component_id: component_id(row, index),
        quantity: row["quantity #{index}"].to_i,
        memo: row["memo #{index}"],
        price_point: price_point(row, index)
      }

      allocations << allocation
      index += 1
    end

    allocations
  end

  def price_point(row, index)
    if present?(row["component price point id #{index}"])
      row["component price point id #{index}"].to_i
    else
      row["component price point handle #{index}"]
    end
  end

  def component_id(row, index)
    if present?(row["component id #{index}"])
      row["component id #{index}"]
    else
      "handle:#{URI.encode_www_form_component(row["component handle #{index}"])}"
    end
  end
end
