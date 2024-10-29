# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'pry'
require 'sinatra'
require_relative 'db/redis_client'
require_relative 'db/local_keystore'
require_relative 'models/config'
require_relative 'models/data_sources/csv_source'
require_relative 'models/data_sources/json_source'
require_relative 'models/data_sources/mock_data_source'
require_relative 'models/importer'
require_relative 'workflows/build_workflow'

# sinatra setup
set :bind, '0.0.0.0'
port = ENV['PORT'] || '8080'
set :port, port
enable :sessions
set :session_store, Rack::Session::Pool

# use dotenv for local testing
Dotenv.load('config/.env') unless ENV['RUNNING_ON_SERVER']

# basic auth
use Rack::Auth::Basic, 'Restricted Area' do |username, password|
  username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
end

keystore = RedisClient.new(ENV['REDIS_URL'], ENV['REDIS_USERNAME'], ENV['REDIS_PASSWORD'])
# keystore = LocalKeystore.new

get '/' do
  'It works!'
end

# placeholder route to start import
post '/start' do
  puts 'Starting import...'

  config = Config.new(
    api_key: request.env['HTTP_APIKEY'],
    subdomain: request.env['HTTP_SUBDOMAIN'],
    domain: request.env['HTTP_DOMAIN']
  )

  request.body.rewind
  template_name = request.env['HTTP_TEMPLATE']
  source_type = request.env['HTTP_SOURCE_TYPE']
  data = case source_type
         when 'CSV'
           CSVSource.new(request.body.read)
         when 'JSON'
           JSONSource.new(request.body.read)
         else
           MockData.new(template_name, 50)
         end

  workflow = BuildWorkflow.for(template_name)
  importer = Importer.new(config, workflow, data, keystore)

  Thread.new do
    importer.start
  end

  content_type :json
  { message: 'started', import_id: importer.id }.to_json
end

get '/status' do
  import_id = params[:id]
  puts "import id: #{import_id}"
  content_type :json
  return { error: 'Import ID required' }.to_json unless import_id

  data = keystore.get(import_id)
  status 404 unless data
  return { error: 'Import ID not found' }.to_json unless data

  puts 'data found'

  data['run_time'] = Importer.calculate_run_time(data['created_at']) unless data['completed_at']
  data.to_json
end

post '/clear' do
  import_id = params[:id]
  content_type :json
  return { error: 'Import ID required' }.to_json unless import_id

  keystore.del(import_id)

  { message: 'cleared', import_id: import_id }.to_json
end
