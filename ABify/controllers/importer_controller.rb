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
  get '/' do
    'It works!'
  end

  post '/start' do
    @request = request
    request.body.rewind

    config = build_config

    begin
      data = load_data_by_type
    rescue StandardError => e
      status 422
      return { error: e.message }.to_json
    end

    workflow = BuildWorkflow.for(request.env['HTTP_TEMPLATE'])
    importer = Importer.new(config, workflow, data)

    Thread.new do
      importer.start
    end

    content_type :json
    { message: 'started', import_id: importer.id }.to_json
  end

  private

  def build_config
    Config.new(
      api_key: @request.env['HTTP_APIKEY'],
      subdomain: @request.env['HTTP_SUBDOMAIN'],
      domain: @request.env['HTTP_DOMAIN'],
      keystore: LocalKeystore.instance
    )
  end

  def load_data_by_type
    {
      'csv' => method(:load_csv_data),
      'json' => method(:load_json_data),
      'mock' => method(:load_mock_data)
    }.fetch(@request.env['HTTP_SOURCE_TYPE']).call
  rescue KeyError
    raise 'Invalid source type'
  end

  def load_csv_data
    CsvData.new(@request.env['HTTP_FILE_PATH'])
  rescue StandardError => e
    raise "Error loading CSV: #{e.message}"
  end

  def load_json_data
    JsonData.new(@request.body.read)
  end

  def load_mock_data
    row_count = @request.env['HTTP_ROW_COUNT']&.to_i
    template_name = @request.env['HTTP_TEMPLATE']
    raise 'Row count required for mock data' unless row_count&.positive?

    MockData.new(template_name, row_count)
  end
end
