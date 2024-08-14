# frozen_string_literal: true

require 'typhoeus'
require 'json'
require_relative 'step_callback_handler'
require 'pry'

# This class builds/handles import template "steps"
# Each template can have one or many steps that need to run in sequence
class Step
  attr_reader :skip, :required, :url, :method, :response_key, :response_val, :response_text, :json, :name

  def initialize(name:, required:, url:, method:, response_key:, skip: nil, response_val: nil,
                 response_text: nil, json: nil)
    @skip = skip
    @name = name
    @required = required
    @url = url
    @method = method
    @response_key = response_key
    @response_val = response_val
    @response_text = response_text
    @json = json
  end

  # Queue a step to be run using Typhoeus/Hydra.
  # When the step completes, following steps are added to the queue
  def enqueue(row, hydra, next_steps, config, is_first_step: true)
    callback_handler = StepCallbackHandler.new(self, row, next_steps, hydra, config)
    if @skip&.call(row.data)
      callback_handler.queue_next_step(is_first_step: is_first_step)
      return
    end

    request = build_typh_request(row.data, config)

    # parse response and handle next steps
    request.on_complete do |response|
      callback_handler.handle_response(response)
    end

    if is_first_step
      hydra.queue(request) # Add first step to the end of the queue
    else
      hydra.queue_front(request) # Prioritize completing rows before starting new ones
    end
  end

  private

  # Build HTTP request based on the template step
  def build_typh_request(row, config)
    request_url = @url.call(row, config)
    request_method = @method.downcase.to_sym
    request_body = @json ? @json.call(row).to_json : nil

    Typhoeus::Request.new(
      request_url,
      method: request_method,
      body: request_body,
      headers: { 'Content-Type' => 'application/json' },
      # proxy: 'http://localhost:8080',
      userpwd: "#{config.api_key}:x",
      timeout: 120
    )
  end

  # queues the next template step to be run
  # if there are no more steps, the row is complete
  def queue_next_step(next_steps, row, hydra, config, is_first_step: false)
    return unless next_steps.any?

    next_step = next_steps.first
    next_step.enqueue(row, hydra, next_steps.drop(1), config, is_first_step: is_first_step)
  end
end
