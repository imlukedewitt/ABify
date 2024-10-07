# frozen_string_literal: true

# json payloads
module Payloads
  # component json payloads
  module Components
    require_relative '../helpers/utils'
    require_relative '../helpers/string_utils'
    extend Utils
    extend StringUtils

    def self.create_components(row)
      json = {
        name: row['name'],
        description: row['description'],
        unit_name: row['unit name'],
        handle: row['component handle'],
        recurring: row['recurring'],
        default_price_point_name: row['price point name'],
        default_price_point_handle: row['price point handle'],
        pricing_scheme: row['pricing scheme'],
        taxable: row['taxable'],
        tax_code: row['tax code'],
        tax_included: row['tax included'],
        allow_fractional_quantities: row['allow fractional quantities'],
        hide_date_range_on_invoice: row['hide date range on invoice'],
        display_on_hosted_page: row['allow billing portal updates'],
        upgrade_charge: row['upgrade charge'],
        downgrade_credit: row['downgrade credit'],
        unit_price: row['unit price'],
        event_based_billing_metric_id: row['metric id'],
        rollover_prepaid_remainder: row['allow rollover'],
        renew_prepaid_allocation: row['auto renew units'],
        interval: row['interval'],
        interval_unit: row['interval unit'],
        item_category: row['item category']
      }

      # Price tiers
      scheme = row['pricing scheme'] == 'on_off' ? '' : row['pricing scheme']
      json[:prices] = if ['per_unit', ''].include?(scheme)
                        [{ starting_quantity: 1, unit_price: row['unit price'] }]
                      else
                        row.keys.select { |key| key =~ /^price \d+$/ }.map do |key|
                          next unless present?(row[key])

                          i = key.match(/\d+$/)[0].to_i
                          {
                            starting_quantity: row["starting quantity #{i}"],
                            ending_quantity: row["ending quantity #{i}"],
                            unit_price: row[key]
                          }
                        end.compact
                      end

      # Overage pricing
      if present?(row['overage pricing scheme'])
        json[:overage_pricing] = { pricing_scheme: row['overage pricing scheme'] }
        json[:overage_pricing][:prices] = if row['overage pricing scheme'] == 'per_unit'
                                            [{ starting_quantity: 1, unit_price: row['overage unit price'] }]
                                          else
                                            row.keys.select { |key| key =~ /^overage price \d+$/ }.map do |key|
                                              next unless row[key]

                                              i = key.match(/\d+$/)[0].to_i
                                              {
                                                starting_quantity: row["overage starting quantity #{i}"],
                                                ending_quantity: row["overage ending quantity #{i}"],
                                                unit_price: row[key]
                                              }
                                            end.compact
                                          end
      end

      component_type = "#{row['component type']}_component"
      component_json = { component_type => json }
      trim_payload(component_json)
    end

    def self.create_price_points(row)
      json = {
        price_point: {
          name: row['price point name'],
          handle: row['price point handle'],
          renew_prepaid_allocation: row['auto renew units'],
          rollover_prepaid_remainder: row['allow rollover'],
          expiration_interval: row['expire after'],
          expiration_interval_unit: row['month or day'],
          pricing_scheme: row['pricing scheme'],
          tax_included: row['tax included'],
          interval: row['interval'],
          interval_unit: row['interval unit']
        }
      }

      # Prices
      scheme = row['pricing scheme'] == 'on_off' ? '' : row['pricing scheme']
      json[:price_point][:prices] = if ['per_unit', ''].include?(scheme)
                                      [{ starting_quantity: 1, unit_price: row['unit price'] }]
                                    else
                                      row.keys.select { |key| key =~ /^price \d+$/ }.map do |key|
                                        next unless row[key]

                                        i = key.match(/\d+$/)[0].to_i
                                        {
                                          starting_quantity: row["starting quantity #{i}"],
                                          ending_quantity: row["ending quantity #{i}"],
                                          unit_price: row[key]
                                        }
                                      end.compact
                                    end

      # Overage
      if row['overage pricing scheme']
        json[:price_point][:overage_pricing] = { pricing_scheme: row['overage pricing scheme'] }
        if row['overage pricing scheme'] == 'per_unit'
          json[:price_point][:overage_pricing][:prices] =
            [{ starting_quantity: 1, unit_price: row['overage unit price'] }]
        else
          json[:price_point][:overage_pricing][:prices] = row.keys.select do |key|
                                                            key =~ /^overage price \d+$/
                                                          end.map do |key|
            next unless row[key]

            i = key.match(/\d+$/)[0].to_i
            {
              starting_quantity: row["overage starting quantity #{i}"],
              ending_quantity: row["overage ending quantity #{i}"],
              unit_price: row[key]
            }
          end.compact
        end
      end

      trim_payload(json)
    end
  end
end
