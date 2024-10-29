# frozen_string_literal: true

require 'json'

# placeholder until I get local redis going
class LocalKeystore
  def initialize
    @store = {}
    @mutex = Mutex.new
  end

  def set(key, value)
    @mutex.synchronize do
      @store[key] = value
    end
  end

  def get(key)
    @mutex.synchronize do
      @store[key]
    end
  end

  def del(key)
    @mutex.synchronize do
      @store.delete(key)
    end
  rescue StandardError => e
    puts "Error deleting key: #{e}"
  end
end
