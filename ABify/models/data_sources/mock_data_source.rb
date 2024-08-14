# frozen_string_literal: true

require 'faker'
require_relative 'data_source'
require_relative 'row'

# Placeholder data source
class MockCustomerData < DataSource
  attr_reader :rows

  def initialize(count = 50)
    super()
    @rows = generate_data(count)
  end

  def generate_data(rows = 50)
    rows.times.with_index(1).map do |idx|
      email = if rand < 0.05
                'invalid_email'
              else
                Faker::Internet.email
              end

      customer = {
        'first name' => Faker::Name.first_name,
        'last name' => Faker::Name.last_name,
        'email' => email,
        'create payment profile' => true,
        'current vault' => 'bogus',
        'vault token' => '1'
      }
      Row.new(customer, idx)
    end
  end
end
