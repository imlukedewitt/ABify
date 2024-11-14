# frozen_string_literal: true

require 'singleton'
require 'redis'

# RedisKeystore is a singleton class that provides a simple interface to Redis
class RedisKeystore
  include Singleton

  def initialize
    @redis = Redis.new(host: 'redis_db', port: 6379)
  end

  def set(key, value)
    @redis.set(key, value.to_json)
  rescue StandardError => e
    puts "Error setting key: #{e}"
  end

  def get(key)
    value = @redis.get(key)
    value ? JSON.parse(value) : nil
  rescue JSON::ParserError
    value
  rescue StandardError => e
    puts "Error getting key: #{e}"
    nil
  end

  def del(key)
    @redis.del(key)
  rescue StandardError => e
    puts "Error deleting key: #{e}"
  end
end
