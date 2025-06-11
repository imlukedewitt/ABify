# frozen_string_literal: true

require 'uri'
require_relative '../workflow'
require_relative '../../helpers/string_utils'
require_relative '../../helpers/utils'
require_relative '../../models/step'

# builds the Delete Subscriptions workflow
class DeleteSubscriptions < Workflow
  def unbuilt_steps
    [
      {
        name: 'delete subscription',
        required: true,
        url: lambda { |row, config|
          url = "#{config.base_url}/subscriptions/#{row['subscription id']}/purge.json?ack=#{row['customer id']}"
          url += "&cascade[]=customer" if true?(row['delete customer'])
          url
        },
        method: :post,
        response_key: 'subscription id',
        response_val: ->(_result) { 'deleted subscription' },
        response_text: ->(_result, _config) { "subscription deleted" }
      }
    ]
  end
end
