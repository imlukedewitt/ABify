# frozen_string_literal: true

require_relative 'customers/create_customers'
require_relative 'components/create_components'

# Simple workflow initializer
module BuildWorkflow
  WORKFLOWS = {
    # placeholder naming convention
    'createCustomers' => CreateCustomers,
    'createComponents' => CreateComponents
  }.freeze

  def self.for(name)
    raise "Workflow not found: #{name}" unless WORKFLOWS.key?(name)

    WORKFLOWS[name].new
  end
end
