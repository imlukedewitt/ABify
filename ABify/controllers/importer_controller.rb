# frozen_string_literal: true

require 'sinatra/base'
require_relative '../db/local_keystore'
require_relative '../models/config'
require_relative '../models/data_sources/csv_source'
require_relative '../models/data_sources/json_source'
require_relative '../models/data_sources/mock_data_source'
require_relative '../models/importer'
require_relative '../workflows/build_workflow'

# ImporterController
class ImporterController < Sinatra::Base
  keystore = LocalKeystore.instance

  get '/' do
    'It works!'
  end

  post '/start' do
    puts 'Starting import...'

    config = Config.new(
      api_key: request.env['HTTP_APIKEY'],
      subdomain: request.env['HTTP_SUBDOMAIN'],
      domain: request.env['HTTP_DOMAIN'],
      keystore: keystore
    )

    request.body.rewind
    template_name = request.env['HTTP_TEMPLATE']
    source_type = request.env['HTTP_SOURCE_TYPE']

    data = case source_type
           when 'csv'
             begin
               CsvData.new(request.env['HTTP_FILE_PATH'])
             rescue StandardError => e
               status 422
               return { error: "Error loading CSV: #{e.message}" }.to_json
             end
           when 'json'
             JsonData.new(request.body.read)
           when 'mock'
             row_count = request.env['HTTP_ROW_COUNT']&.to_i
             unless row_count
               status 422
               return { error: 'Row count required for mock data' }.to_json
             end
             MockData.new(template_name, row_count)
           else
             status 422
             return { error: 'Invalid source type' }.to_json
           end

    workflow = BuildWorkflow.for(template_name)
    importer = Importer.new(config, workflow, data)

    Thread.new do
      importer.start
    end

    content_type :json
    { message: 'started', import_id: importer.id }.to_json
  end
end
