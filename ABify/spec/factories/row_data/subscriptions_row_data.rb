# frozen_string_literal: true

require 'faker'
require 'factory_bot'

FactoryBot.define do
  factory :create_subscription_row, class: Hash do
    initialize_with do
      PayloadHelpers.base_subscription_data
                    .merge(PayloadHelpers.product_data)
                    .merge(PayloadHelpers.dates_data)
    end

    trait :grouped do
      after(:build) do |row|
        row.merge!(PayloadHelpers.group_data)
      end
    end

    trait :with_coupon do
      after(:build) do |row|
        row.merge!(PayloadHelpers.coupon_data)
      end
    end

    trait :with_component do
      after(:build) do |row|
        row.merge!(PayloadHelpers.component_data)
      end
    end

    trait :with_component_custom_price do
      after(:build) do |row|
        row.merge!(PayloadHelpers.component_custom_price_data)
      end
    end

    trait :with_custom_fields do
      after(:build) do |row|
        row['custom field [field1]'] = Faker::Alphanumeric.alphanumeric(number: 10)
        row['custom field [field2]'] = Faker::Alphanumeric.alphanumeric(number: 10)
      end
    end
  end
end

module PayloadHelpers
  def self.base_subscription_data
    {
      'dunning exempt' => [true, false].sample,
      'customer id' => Faker::Number.number(digits: 4),
      'customer reference' => Faker::Alphanumeric.alphanumeric(number: 10),
      'receives invoice emails' => [true, false].sample,
      'subscription reference' => Faker::Alphanumeric.alphanumeric(number: 10),
      'currency' => Faker::Currency.code,
      'payment collection method' => %w[automatic remittance prepaid].sample,
      'net terms' => Faker::Number.between(from: 0, to: 30),
      'service credit balance' => Faker::Number.between(from: 0, to: 100),
      'prepayment balance' => Faker::Number.between(from: 0, to: 100),
      'referral code' => Faker::Alphanumeric.alphanumeric(number: 5),
      'payment profile id' => Faker::Number.number(digits: 3)
    }
  end

  def self.dates_data
    {
      'activated at' => Faker::Date.backward(days: 60),
      'previous billing at' => Faker::Date.backward(days: 15),
      'next billing at' => Faker::Date.forward(days: 15),
      'initial billing at' => nil,
      'cancelled at' => nil,
      'expires at' => Faker::Date.forward(days: 365)
    }
  end

  def self.group_data
    {
      'subscription group' => 'TRUE',
      'group primary' => [true, false].sample,
      'group payer' => %w[self parent eldest].sample,
      'align billing date' => [true, false].sample
    }
  end

  def self.product_data
    {
      'product' => generate_catalog_handle,
      'product price point' => generate_catalog_handle,
      'product price point handle' => nil
    }
  end

  def self.coupon_data(coupon_idx = 1)
    {
      "coupon #{coupon_idx}" => Faker::Alphanumeric.alphanumeric(number: 10)
    }
  end

  def self.component_data(comp_idx = 1)
    {
      "component #{comp_idx}" => generate_catalog_handle,
      "component quantity #{comp_idx}" => Faker::Number.between(from: 1, to: 10),
      "component price point #{comp_idx}" => generate_catalog_handle
    }
  end

  def self.component_custom_price_data(comp_idx = 1, price_idx = 1)
    {
      "component custom price scheme #{comp_idx}" => 'per_unit',
      "component per unit price #{comp_idx}" => Faker::Commerce.price,
      "component #{comp_idx} starting quantity #{price_idx}" => 1,
      "component #{comp_idx} ending quantity #{price_idx}" => 10,
      "component #{comp_idx} unit price #{price_idx}" => Faker::Commerce.price,

      "component custom overage price scheme #{comp_idx}" => 'per_unit',
      "component #{comp_idx} overage starting quantity #{price_idx}" => 1,
      "component #{comp_idx} overage ending quantity #{price_idx}" => 10,
      "component #{comp_idx} overage unit price #{price_idx}" => Faker::Commerce.price
    }
  end

  def self.generate_catalog_handle
    Faker::Commerce.product_name.downcase.gsub(/[^a-z0-9]+/, '-')
  end
end
