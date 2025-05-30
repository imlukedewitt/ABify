# frozen_string_literal: true

require 'uri'
require_relative '../../workflow'
require_relative '../../../helpers/string_utils'
require_relative '../../../helpers/utils'
require_relative '../../../models/step'

# builds the Create EBB Usage workflow
class CreateEvents < Workflow
  def unbuilt_steps
    [
      create_ebb_usage_step
    ]
  end

  private

  def create_ebb_usage_step
    {
      name: 'send EBB Usage',
      required: true,
      method: :post,
      url: lambda { |row, config|
        domain = row['domain'] || config.domain
        subdomain = row['subdomain'] || config.subdomain
        api_handle = URI.encode_www_form_component(row['api handle'])
        url = "https://events.#{domain}/#{subdomain}/events/#{api_handle}.json"
        url += "?store_uid=#{URI.encode_www_form_component(row['store uid'])}" if present?(row['store uid'])
        url
      },
      json: lambda { |row|
        payload = {}

        row.each do |key, value|
          next unless key.start_with?('event.')

          path = key.split('.')
          path.shift # remove 'event' prefix
          sub_object = payload
          while path.length > 1
            part = path.shift
            sub_object[part] ||= {}
            sub_object = sub_object[part]
          end

          # Convert to number if numeric
          value = value.to_f if value.to_s =~ /\A-?\d+(\.\d+)?\z/
          sub_object[path[0]] = value
        end

        trim_payload(payload)
      },
      response_text: lambda { |_result, _config|
        "EBB usage event sent successfully"
      },
      response_key: 'success',
      response_val: ->(_result) { true }
    }
  end
end
