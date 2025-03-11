# frozen_string_literal: true

require 'typhoeus'
require 'uri'

# Handles typheous/hydra queue
class HydraManager
  attr_reader :hydra, :requests, :running

  def initialize(api_key:, subdomain:, domain: 'chargify.com', max_concurrency: 25)
    @hydra = Typhoeus::Hydra.new(max_concurrency: max_concurrency)
    @requests = []
    @running = false
    @api_key = api_key
    @subdomain = subdomain
    @domain = domain
  end

  def queue(url:, body:, on_complete:, method: :get, params: {}, front: false)
    options = {
      method: method,
      userpwd: "#{@api_key}:x",
      headers: { 'User-Agent' => 'Agent User', 'Content-Type' => 'application/json' },
      timeout: 120
    }
    options[:body] = body if body
    request = new_request(url, params, options)
    request.on_complete { |resp| on_complete.call(resp) } if on_complete

    @requests << request
    front ? @hydra.queue_front(request) : @hydra.queue(request)
    request
  end

  def run
    @running = true
    @hydra.run
    @running = false
  end

  private

  def new_request(path, params, options)
    Typhoeus::Request.new(build_url(path, params), options)
  end

  def url_param_string(param_hash)
    URI.encode_www_form(param_hash)
  end

  def build_url(path, params)
    base_url = "https://#{@subdomain}.#{@domain}/#{path}"
    return base_url unless params.any?

    "#{base_url}?#{url_param_string(params)}"
  end
end
