# frozen_string_literal: true

require 'faker'
require 'factory_bot'

FactoryBot.define do
  factory :create_customer_row, class: Hash do
    initialize_with do
      {
        'parent customer id' => Faker::Number.number(digits: 4),
        'organization' => Faker::Company.name,
        'customer reference' => Faker::Alphanumeric.alphanumeric(number: 10),
        'first name' => Faker::Name.first_name,
        'last name' => Faker::Name.last_name,
        'email' => Faker::Internet.email,
        'cc emails' => Faker::Internet.email,
        'phone' => Faker::PhoneNumber.phone_number,
        'shipping address' => Faker::Address.street_address,
        'shipping address 2' => Faker::Address.secondary_address,
        'shipping city' => Faker::Address.city,
        'shipping state' => Faker::Address.state,
        'shipping country' => Faker::Address.country,
        'shipping zip' => Faker::Address.zip,
        'tax exempt' => [true, false].sample,
        'vat number' => Faker::Alphanumeric.alphanumeric(number: 10),
        'verified' => [true, false].sample,
        'custom field [field1]' => Faker::Lorem.word,
        'custom field [field2]' => Faker::Lorem.word
      }
    end
  end
end
