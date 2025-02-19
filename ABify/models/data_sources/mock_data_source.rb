# frozen_string_literal: true

require 'faker'
require_relative 'data_source'
require_relative 'row'

# Placeholder data source
class MockData < DataSource
  attr_reader :rows

  def initialize(template, count = 50)
    super()

    case template
    when 'createCustomers'
      generator = method(:mock_create_customers)
    when 'deleteCustomers'
      generator = method(:mock_delete_customers)
    when 'createSubscriptions'
      generator = method(:mock_create_subscriptions)
    else
      raise "Unknown template: #{template}"
    end

    # Generate rows with index
    @rows = count.times.map do |i|
      Row.new(generator.call, i + 1)
    end
  end

  private

  def mock_create_customers
    email = if rand < 0.05
              'invalid_email'
            else
              Faker::Internet.email
            end
    vault = if rand < 0.05
              'invalid_vault'
            else
              'bogus'
            end
    {
      'first name' => Faker::Name.first_name,
      'last name' => Faker::Name.last_name,
      'email' => email,
      'create payment profile' => true,
      'current vault' => vault,
      'vault token' => '1'
    }
  end

  def mock_delete_customers
    {
      'customer reference' => Faker::Alphanumeric.alphanumeric(number: 10)
    }
  end

  def mock_create_subscriptions
    next_billing = (Date.today + rand(1..30))
    {
      'customer reference' => 'test',
      'subscription reference' => Faker::Alphanumeric.alphanumeric(number: 8),
      'product' => 'freemo',
      'next billing at' => next_billing.strftime('%Y-%m-%d'),
      'previous billing at' => (next_billing - 30).strftime('%Y-%m-%d'),
      'component 1' => %w[recurring metered].sample,
      'component price point 1' => %w[original standard].sample,
      'component quantity 1' => rand(1..100)
    }
  end
end
