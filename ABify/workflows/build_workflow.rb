# frozen_string_literal: true

require_relative 'customers/create_customers'
require_relative 'customers/delete_customers'
require_relative 'components/create_components'
require_relative 'subscriptions/create_subscriptions'
require_relative 'subscriptions/subscriptions_components/create_metered_usage'
require_relative 'subscriptions/subscriptions_components/create_allocations'
require_relative 'subscriptions/subscriptions_components/create_bulk_allocations'

# Simple workflow initializer
module BuildWorkflow
  WORKFLOWS = {
    # placeholder naming convention
    'createCustomers' => CreateCustomers,
    'deleteCustomers' => DeleteCustomers,
    'createComponents' => CreateComponents,
    'createSubscriptions' => CreateSubscriptions,
    'createMeteredUsage' => CreateMeteredUsage,
    'createAllocations' => CreateAllocations,
    'createBulkAllocations' => CreateBulkAllocations
  }.freeze

  def self.for(name)
    raise "Workflow not found: #{name}" unless WORKFLOWS.key?(name)

    WORKFLOWS[name].new
  end
end
