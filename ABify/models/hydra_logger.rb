# frozen_string_literal: true

require 'logger'

# Logger for Typhoeus/Hydra requests
class HydraLogger
  def initialize(log_file = 'import.log')
    @logger = Logger.new(log_file)
    @mutex = Mutex.new
    @errors = 0
    @max_row_idx = 0
  end

  def log_response(response, row_idx, row_count, step_name)
    # Update error count and max_row_idx if necessary
    @mutex.synchronize do
      @errors += 1 unless response.success?
      @max_row_idx = [@max_row_idx, row_idx].max
    end

    console_log(row_count)
    file_log(response, row_idx, step_name)
  end

  private

  def console_log(row_count)
    @mutex.synchronize do
      # Add leading 0's
      width = row_count.to_s.length
      formatted_row_idx = @max_row_idx.to_s.rjust(width, '0')
      formatted_errors = @errors.to_s.rjust(width, '0')

      # Print the formatted string
      print "\rProcessed rows: #{formatted_row_idx}/#{row_count} Errors: #{formatted_errors}/#{row_count}"
    end
  end

  def file_log(response, row_idx, step_name)
    message = <<~MESSAGE
      Row #{row_idx}, step: #{step_name}
      #{response.request.options[:method]}: #{response.request.base_url}
      body: #{response.request.options[:body]}
      response: #{response.code} #{response.status_message} #{response.body}
    MESSAGE

    if response.success?
      @logger.info(message)
    else
      @logger.error(message)
    end
  end
end
