# frozen_string_literal: true

# json payloads
module Payloads
  # payment profile json payloads
  module PaymentProfiles
    require_relative '../utils'
    require_relative '../string_utils'
    extend Utils
    extend StringUtils

    def self.create_payment_profiles(row)
      payload = {
        payment_profile: {
          customer_id: row['customer id'],
          payment_type: row['payment profile type'],
          current_vault: row['current vault'],
          gateway_handle: row['gateway handle'],
          vault_token: row['vault token'],
          customer_vault_token: row['customer vault token'],
          paypal_email: row['paypal_email'] || row['paypal email'],
          first_name: row['payment profile first name'],
          last_name: row['payment profile last name'],
          last_four: row['last four'],
          card_type: row['card type'],
          expiration_year: row['expiration year'] || row['exp year'] || nil,
          expiration_month: row['expiration month'] || row['exp month'] || nil,
          bank_name: row['bank name'],
          bank_account_number: row['bank account last four'],
          bank_routing_number: row['bank routing last four'],
          billing_address: row['billing address'],
          billing_address_2: row['billing address 2'],
          billing_city: row['billing city'],
          billing_state: row['billing state'],
          billing_country: row['billing country'],
          billing_zip: row['billing zip'],
          verified: row['stripe verified']
        }
      }

      trim_payload(payload)
    end
  end
end
