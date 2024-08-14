# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'pry'
require_relative 'models/config'
require_relative 'models/data_sources/json_source'
require_relative 'models/data_sources/mock_data_source'
require_relative 'models/data_sources/csv_source'
require_relative 'db/local_keystore'
require_relative 'models/importer'
require_relative 'workflows/build_workflow'

# use dotenv for local testing
Dotenv.load('config/.env') unless ENV['RUNNING_ON_SERVER']

puts 'Starting import...'

keystore = LocalKeystore.new

config = Config.new(
  api_key: ENV['HTTP_APIKEY'],
  subdomain: ENV['HTTP_SUBDOMAIN'],
  domain: ENV['HTTP_DOMAIN']
)

# cx_data = CsvData.new('data/testcx.csv')
# cx_workflow = BuildWorkflow.for('createCustomers')
# cx_importer = Importer.new(config, cx_workflow, cx_data, keystore)
# cx_importer.start

# puts 'Customers imported...'

data = CsvData.new('data/testsubs.csv')
# data = MockCustomerData.new(50)

workflow = BuildWorkflow.for('createSubscriptions')
importer = Importer.new(config, workflow, data, keystore)

importer.start
# puts data.summary.to_json
puts '.'
