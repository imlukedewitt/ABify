# frozen_string_literal: true

# json payloads
module Payloads
  # subscription json payloads
  module Subscriptions
    require_relative 'subscriptions/create_subscriptions'

    def self.create_subscriptions(row)
      CreateSubscriptions.create_subscriptions(row)
    end
  end
end
