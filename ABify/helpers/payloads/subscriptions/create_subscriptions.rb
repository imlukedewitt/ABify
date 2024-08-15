# frozen_string_literal: true

module Payloads
  module Subscriptions
    # json payloads for creating subscriptions
    module CreateSubscriptions
      require_relative '../../string_utils'
      require_relative '../../utils'

      extend Utils
      extend StringUtils

      def self.create_subscriptions(row)
        payload = {
          subscription: {
            dunning_exempt: row['dunning exempt'],
            import_mrr: row['initial billing at'] ? false : true,
            customer_id: row['customer id'],
            customer_reference: customer_reference(row),
            receives_invoice_emails: row['receives invoice emails'],
            reference: row['subscription reference'],
            currency: row['currency'],
            payment_collection_method: row['payment collection method'],
            previous_billing_at: row['previous billing at'].to_s,
            next_billing_at: row['next billing at'].to_s,
            initial_billing_at: row['initial billing at'],
            canceled_at: row['canceled at'] || row['cancelled at'],
            activated_at: row['activated at'],
            expires_at: row['expires at'],
            net_terms: row['net terms'],
            service_credit_balance: row['service credit balance'],
            prepayment_balance: row['prepayment balance'],
            product_handle: row['product'],
            product_price_point_handle: row['product price point'] || row['product price point handle'],
            ref: row['referral code'],
            payment_profile_id: payment_profile_id(row),
            group: group(row),
            coupon_codes: coupon_codes(row),
            components: components(row)
          }
        }
        trim_payload(payload)
      end

      def self.customer_reference(row)
        blank?(row['customer id']) ? row['customer reference'] : nil
      end

      def self.payment_profile_id(row)
        return unless row['who pays'] == 'self' || row['invoice type'] != 'consolidated'

        row['payment profile id']
      end

      def self.group(row)
        return unless true?(row['subscription group'])

        {
          target: {
            type: row['group payer']
          },
          billing: {
            align_date: row['align billing date']
          }
        }
      end

      def self.coupon_codes(row)
        row.keys.select { |key| key =~ /^coupon \d+$/ }.map { |key| row[key] }
      end

      def self.components(row)
        row.keys.select { |key| key =~ /^component \d+$/ }.map do |key|
          idx = key.match(/\d+/)[0].to_i
          component(row, idx)
        end.compact
      end

      def self.component(row, idx)
        quantity = row["component quantity #{idx}"]
        return if blank?(quantity)

        price_point = present?(row["component price point #{idx}"]) ? "handle:#{row["component price point #{idx}"]}" : nil
        component = {
          component_id: "handle:#{row["component #{idx}"]}",
          allocated_quantity: quantity,
          unit_balance: quantity
        }

        if present?(custom_price_scheme)
          component[:custom_price] = custom_price(row, idx)
        else
          component[:price_point] = price_point
        end

        component
      end

      def self.custom_price(row, idx)
        scheme = row["component custom price scheme #{idx}"] unless blank?(row["component custom price scheme #{idx}"])

        custom_price = {
          pricing_scheme: scheme,
          rollover_prepaid_remainder: row["component #{idx} rollover of units"],
          renew_prepaid_allocation: row["component #{idx} recurring allocations"],
          interval: row["component interval #{idx}"],
          interval_unit: row["component interval unit #{idx}"]
        }

        custom_price[:prices] = custom_prices(row, idx, scheme)
        if present?(row["component custom overage price scheme #{idx}"])
          custom_price[:overage_pricing] = custom_overage_pricing(row, idx)
        end

        custom_price
      end

      def self.custom_prices(row, idx, scheme)
        if scheme == 'per_unit' || blank?(scheme)
          [{
            starting_quantity: 1,
            unit_price: row["component per unit price #{idx}"]
          }]
        else
          regex = /component #{idx} starting quantity/
          row.keys.select { |key| regex.match?(key) }.map do |key|
            j = key.match(/\d+$/)[0].to_i
            next unless row["component #{idx} unit price #{j}"]

            {
              starting_quantity: row["component #{idx} starting quantity #{j}"],
              ending_quantity: row["component #{idx} ending quantity #{j}"],
              unit_price: row["component #{idx} unit price #{j}"]
            }
          end.compact
        end
      end

      def self.custom_overage_pricing(row, idx)
        unless blank?(row["component custom overage price scheme #{i}"])
          scheme = row["component custom overage price scheme #{i}"]
        end
        regex = /component #{idx} overage starting quantity/
        {
          pricing_scheme: scheme,
          prices: row.keys.select { |key| regex.match?(key) }.map do |key|
            j = key.match(/\d+$/)[0].to_i
            next unless row["component #{idx} overage unit price #{j}"]

            {
              starting_quantity: row["component #{idx} overage starting quantity #{j}"],
              ending_quantity: row["component #{idx} overage ending quantity #{j}"],
              unit_price: row["component #{idx} overage unit price #{j}"]
            }
          end.compact
        }
      end

      private_class_method :customer_reference, :payment_profile_id, :group, :coupon_codes, :components, :component,
                           :custom_price, :custom_prices, :custom_overage_pricing
    end
  end
end
