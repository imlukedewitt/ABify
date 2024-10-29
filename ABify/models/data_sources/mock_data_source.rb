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
end
