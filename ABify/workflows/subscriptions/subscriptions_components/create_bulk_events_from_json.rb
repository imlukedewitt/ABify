# frozen_string_literal: true

require 'uri'
require_relative '../../workflow'
require_relative '../../../helpers/string_utils'
require_relative '../../../helpers/utils'
require_relative '../../../models/step'

# builds the Create Bulk Events from JSON workflow
# this uses the api endpoint for bulk events
# instead of the typical row from a CSV, this workflow expects a JSON file
# the JSON file should be structured as an array of objects
class CreateBulkEventsFromJson < Workflow
  def unbuilt_steps
    [
      ebb_step
    ]
  end

  private

  def ebb_step
    {
      name: 'send bulk EBB Usage',
      required: true,
      method: :post,
      url: lambda { |row, config|
        domain = row['domain'] || config.domain
        subdomain = row['subdomain'] || config.subdomain
        api_handle = URI.encode_www_form_component(row['api handle'])
        url = "https://events.#{domain}/#{subdomain}/events/#{api_handle}/bulk.json"
        url += "?store_uid=#{URI.encode_www_form_component(row['store uid'])}" if present?(row['store uid'])
        url
      },
      json: ->(row) { trim_payload(row['event data']) },
      response_text: ->(_, _) { 'Bulk EBB usage events sent successfully' },
      response_key: 'success',
      response_val: ->(_) { true }
    }
  end
end
