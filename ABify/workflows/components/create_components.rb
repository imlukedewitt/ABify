# frozen_string_literal: true

require 'uri'
require_relative '../workflow'
require_relative '../../helpers/string_utils'
require_relative '../../helpers/utils'
require_relative '../../models/step'

# builds the Create Components workflow
class CreateComponents < Workflow
  def unbuilt_steps
    [
      lookup_product_family_id_step,
      create_component_step,
      create_price_point_step
    ]
  end

  private

  def lookup_product_family_id_step
    {
      name: 'lookup product family ID',
      required: true,
      skip: ->(row) { present?(row['product family id']) },
      url: ->(row, config) { product_family_url(row, config) },
      method: :get,
      response_key: 'product family id',
      response_val: ->(result) { result['product_family']['id'] }
    }
  end

  def product_family_url(row, config)
    product_family = URI.encode_www_form_component(row['product family handle'])
    "#{config.base_url}/product_families/lookup.json?handle=#{product_family}"
  end

  def create_component_step
    {
      name: 'create component',
      required: true,
      skip: ->(row) { blank?(row['name']) && blank?(row['component handle']) },
      url: ->(row, config) { component_url(row, config) },
      method: :post,
      json: Payloads::Components.method(:create_components),
      response_key: 'component id',
      response_val: ->(result) { result['component']['id'] },
      response_text: ->(result, config) { component_response_text(result, config) }
    }
  end

  def component_url(row, config)
    component_type = URI.encode_www_form_component("#{row['component type']}_components")
    "#{config.base_url}/product_families/#{row['product family id']}/#{component_type}.json"
  end

  def component_response_text(result, config)
    product_family_id = result['component']['product_family_id']
    component_type = result['component']['kind']
    component_id = result['component']['id']
    price_point_id = result['component']['default_price_point_id']
    "#{config.base_url}/product_families/#{product_family_id}/#{component_type}s/#{component_id}?price_point_id#{price_point_id}"
  end

  def create_price_point_step
    {
      name: 'create component price point',
      required: true,
      skip: ->(row) { present?(row['name']) && present?(row['component handle']) },
      url: ->(row, config) { price_point_url(row, config) },
      method: :post,
      json: Payloads::Components.method(:create_price_points),
      response_key: 'price point id',
      response_val: ->(result) { result['price_point']['id'] },
      response_text: ->(result, _config) { "/price_points/#{result['price_point']['id']}" }
    }
  end

  def price_point_url(row, config)
    component_handle = URI.encode_www_form_component(row['attach to'])
    "#{config.base_url}/components/handle:#{component_handle}/price_points.json"
  end
end
