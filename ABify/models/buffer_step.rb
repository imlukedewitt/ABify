# frozen_string_literal: true

require 'typhoeus'

# This is a "fake" step that is added to the start of every workflow. This
# makes it possible to stop the import while it's running.
#
# We only want to stop rows that haven't started processing yet, and hydra
# immediately queues the first step for every row in the import. By adding a
# fake step that calls localhost, we can stop the import before the real first
# step is queued for pending rows.
class BufferStep
  def initialize(config)
    @keystore = config.keystore
    @id = config.id
  end

  def enqueue(row, hydra, steps)
    request = buffer_request
    request.on_complete do
      queue_next_step(steps, row, hydra) if keep_running
    end

    hydra.queue(request)
  end

  private

  def buffer_request
    Typhoeus::Request.new('http://localhost:6789', method: :get)
  end

  def queue_next_step(steps, row, hydra)
    return if steps.empty?

    first_step = steps.first
    first_step.enqueue(row, hydra, steps.drop(1))
  end

  def keep_running
    stop_key = @keystore.get("#{@id}-stop")
    stop_key.nil? || stop_key == 'false'
  end
end
