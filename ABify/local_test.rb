# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'pry'
require_relative 'models/config'
require_relative 'models/data_sources/json_source'
require_relative 'models/data_sources/mock_data_source'
require_relative 'models/data_sources/csv_source'
require_relative 'models/importer'
require_relative 'workflows/build_workflow'

# use dotenv for local testing
Dotenv.load('config/.env') unless ENV['RUNNING_ON_SERVER']

puts 'Starting import...'

config = Config.new(
  api_key: ENV['HTTP_API_KEY'],
  subdomain: ENV['HTTP_SUBDOMAIN'],
  domain: ENV['HTTP_DOMAIN']
)

# data = CsvData.new('data/data.csv')
data = MockCustomerData.new(50)

workflow = BuildWorkflow.for('createCustomers')
importer = Importer.new(config, workflow, data)

importer.start
# puts data.summary.to_json
