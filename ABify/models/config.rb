# frozen_string_literal: true

require_relative 'firestore_client'

# Helper class to store API details
# This is used to create HTTP requests and build URLs from template steps
# (This is only a Class so I can use config.base_url syntax)
class Config
  attr_accessor :api_key, :subdomain, :domain, :row_count, :logger

  def initialize(api_key:, subdomain:, domain: 'chargify.com')
    @api_key = api_key
    @subdomain = subdomain
    @domain = domain
  end

  def base_url
    "https://#{@subdomain}.#{@domain}"
  end
end
