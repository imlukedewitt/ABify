# frozen_string_literal: true

require_relative '../db/local_keystore'

# Helper class to store API/Importer details
class Config
  attr_accessor :api_key, :subdomain, :domain, :row_count, :logger, :keystore, :id

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
