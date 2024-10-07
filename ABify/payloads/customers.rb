# frozen_string_literal: true

# json payloads
module Payloads
  # customer json payloads
  module Customers
    require_relative '../helpers/utils'
    require_relative '../helpers/string_utils'
    extend Utils
    extend StringUtils

    def self.create_customers(row)
      payload = {
        customer: {
          parent_id: row['parent customer id'],
          organization: row['organization'],
          reference: row['customer reference'],
          first_name: row['first name'],
          last_name: row['last name'],
          email: row['email'],
          cc_emails: row['cc emails'],
          phone: row['phone'],
          address: row['shipping address'],
          address_2: row['shipping address 2'],
          city: row['shipping city'],
          state: row['shipping state'],
          country: row['shipping country'],
          zip: row['shipping zip'],
          tax_exempt: row['tax exempt'],
          vat_number: row['vat number'],
          verified: row['verified'],
          metafields: row.keys.select { |key| key.match(/custom field \[.+\]/) }.each_with_object({}) do |key, obj|
            custom_field_name = key.match(/\[(.*)\]/)[1]
            obj[custom_field_name] = row[key]
          end
        }
      }
      trim_payload(payload)
    end
  end
end
