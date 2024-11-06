# frozen_string_literal: true

require_relative '../db/local_keystore'

# Helper class to store API details
# This is used to create HTTP requests and build URLs from template steps
# (This is only a Class so I can use config.base_url syntax)
class Config
  attr_accessor :api_key, :subdomain, :domain, :row_count, :logger, :keystore

  def initialize(api_key:, subdomain:, domain: 'chargify.com', keystore: nil)
    @api_key = api_key
    @subdomain = subdomain
    @domain = domain
    @keystore = keystore
  end

  def base_url
    "https://#{@subdomain}.#{@domain}"
  end
end
