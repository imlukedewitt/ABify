# frozen_string_literal: true

require 'sinatra/base'
require_relative '../db/local_keystore'
require_relative '../helpers/utils'
require_relative '../helpers/string_utils'
require_relative '../models/config'
require_relative '../models/data_sources/csv_source'
require_relative '../models/data_sources/json_source'
require_relative '../models/data_sources/json_file_source'
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
    max_concurrency = (request.env['HTTP_MAX_CONCURRENCY'] || 25).to_i
    importer = Importer.new(config, workflow, data, max_concurrency: max_concurrency)

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

    include_rows = true?(params[:include_rows])
    if data && data[:rows].is_a?(Array)
      if include_rows
        data[:rows] = data[:rows].map do |row|
          row.delete(:data) unless true?(params[:data])
          row.delete(:requests) unless true?(params[:requests])
          row
        end
      else
        data.delete(:rows)
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

  get '/download_csv' do
    import_id = params[:id]
    halt 422, { error: 'Import ID required' }.to_json unless import_id

    file_path = File.join('out', "#{import_id}.csv")
    halt 404, { error: 'CSV file not found' }.to_json unless File.exist?(file_path)

    content_type 'text/csv'
    attachment "#{import_id}.csv"
    send_file file_path
  end

  post '/clear' do
    import_id = params[:id]
    content_type :json
    status 422 unless import_id
    return { error: 'Import ID required' }.to_json unless import_id

    LocalKeystore.instance.del(import_id)
    LocalKeystore.instance.del("#{import_id}-stop")

    GC.start

    { message: 'cleared', import_id: import_id }.to_json
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
      'mock' => method(:load_mock_data),
      'json_file' => method(:load_json_file_data)
    }.fetch(@request.env['HTTP_SOURCE_TYPE']).call
  rescue KeyError
    raise 'Invalid source type'
  end

  def load_csv_data
    if params[:file] && params[:file][:tempfile]
      CsvData.new(params[:file][:tempfile])
    else
      CsvData.new(@request.env['HTTP_FILE_PATH'])
    end
  rescue StandardError => e
    raise "Error loading CSV: #{e.message}"
  end

  def load_json_data
    if params[:file] && params[:file][:tempfile]
      JsonData.new(params[:file][:tempfile])
    else
      JsonData.new(@request.body.read)
    end
  end

  def load_json_file_data
    file_path = @request.env['HTTP_FILE_PATH']
    JsonFileSource.new(file_path)
  rescue StandardError => e
    raise "Error loading JSON file: #{e.message}"
  end

  def load_mock_data
    row_count = @request.env['HTTP_ROW_COUNT']&.to_i
    template_name = @request.env['HTTP_TEMPLATE']
    raise 'Row count required for mock data' unless row_count&.positive?

    MockData.new(template_name, row_count)
  end
end
