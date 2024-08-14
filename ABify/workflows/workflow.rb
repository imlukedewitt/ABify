# frozen_string_literal: true

require_relative '../helpers/payloads/payloads'
require_relative '../models/step'
require_relative '../helpers/string_utils'
require_relative '../helpers/utils'

# The Workflow class initializes an array of Steps.
# The Workflow is used by the Import class to run the steps.
class Workflow
  attr_accessor :steps

  include StringUtils
  include Utils

  def initialize
    @steps = []
    initialize_steps if respond_to?(:unbuilt_steps)
  end

  def add_step(step)
    @steps << step
  end

  def initialize_steps
    unbuilt_steps.each do |step_attrs|
      add_step(Step.new(**step_attrs))
    end
  end
end
