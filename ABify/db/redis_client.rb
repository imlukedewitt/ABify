# redis_client.rb
require 'typhoeus'
require 'json'

class RedisClient
  def initialize(base_url, username, password)
    @base_url = base_url
    @username = username
    @password = password
  end

  def set(key, value)
    request(:post, 'set', { key: key, value: value })
  end

  def get(key)
    response = request(:get, 'get', { key: key })
    response ? JSON.parse(response.body) : nil
  end

  def delete(key)
    request(:post, 'delete', { key: key })
  end

  private

  def request(method, endpoint, params)
    options = {
      headers: { 'Content-Type' => 'application/json' },
      userpwd: "#{@username}:#{@password}"
    }

    case method
    when :post
      options[:body] = params.to_json
      response = Typhoeus.post("#{@base_url}/#{endpoint}", options)
    when :get
      options[:params] = params
      response = Typhoeus.get("#{@base_url}/#{endpoint}", options)
    end

    response.success? ? response : nil
  end
end
