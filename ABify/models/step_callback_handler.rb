# frozen_string_literal: true

# Class to help handle HTTP responses from Typhoeus
class StepCallbackHandler
  def initialize(step, row, next_steps, hydra, config)
    @step = step
    @row = row
    @next_steps = next_steps
    @hydra = hydra
    @config = config
    @logger = config.logger
  end

  # handles the HTTP response & queues next steps
  def handle_response(response)
    @logger.log_response(response, @row.index, @config.row_count, @step.name)
    store_request(response)
    if response.success?
      process_success(response)
      queue_next_step
    else
      process_error(response)
      queue_next_step unless @step.required
    end
  end

  # queues the next template step to be run
  # if there are no more steps, the row is complete
  def queue_next_step
    if @next_steps.empty?
      @row.status = 'complete' if @row.status != 'error'
      return
    end

    next_step = @next_steps.first
    next_step.enqueue(@row, @hydra, @next_steps.drop(1))
  end

  private

  def process_success(response)
    parsed_response = parse_response(response)

    response_val = get_response_val(parsed_response)
    @row.data[@step.response_key] = response_val if response_val
    response_text = get_response_text(parsed_response)
    return unless response_text

    @row.responses ||= []
    @row.responses << { step: @step.name, text: response_text, key: @step.response_key, value: response_val }
  end

  def process_error(response)
    @row.status = 'error' if @step.required
    code = response.code
    parsed_response = parse_response(response)
    parsed_response = parsed_response['errors'] if parsed_response['errors']
    @row.errors ||= []
    @row.errors << { step: @step.name, text: parsed_response, code: code }
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    response_string = response.code.to_s
    response_string += ": #{response.body}" if response.body
    response_string
  end

  def get_response_val(response)
    @step.response_val&.call(response)
  rescue StandardError => _e
    response
  end

  def get_response_text(response)
    @step.response_text&.call(response, @config)
  rescue StandardError => _e
    response
  end

  def store_request(response)
    req = response.request
    @row.requests ||= []
    @row.requests << {
      step: @step.name,
      url: req.base_url,
      method: req.options[:method],
      body: @step.json ? @step.json.call(@row.data) : nil
    }
  end
end
