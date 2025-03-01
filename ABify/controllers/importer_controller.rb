# frozen_string_literal: true

require 'sinatra/base'
require_relative '../db/local_keystore'
require_relative '../helpers/utils'
require_relative '../helpers/string_utils'
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

  get '/status' do
    extend Utils
    extend StringUtils
    import_id = params[:id]
    status 422 unless import_id
    return { error: 'Import ID required' }.to_json unless import_id

    data = LocalKeystore.instance.get(import_id)
    status 404 unless data
    return { error: 'Import ID not found' }.to_json unless data

    data = Marshal.load(Marshal.dump(data)) # deep copy to avoid modifying original data
    data[:run_time] = duration(data[:created_at], data[:completed_at])

    remove_original_data = false?(params[:data])
    if remove_original_data && data && data[:data].is_a?(Array)
      data[:data] = data[:data].map do |row|
        row.delete(:data)
        row
      end
    end

    content_type :json
    data.to_json
  end

  post '/stop' do
    import_id = params[:id]
    content_type :json
    status 422 unless import_id
    return { error: 'Import ID required' }.to_json unless import_id

    importer = LocalKeystore.instance.get(import_id)
    status 404 unless importer
    return { error: 'Import ID not found' }.to_json unless importer

    LocalKeystore.instance.set("#{import_id}-stop", true)

    { message: 'stopping', import_id: import_id }.to_json
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
