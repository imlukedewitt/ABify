# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'pry'
require 'sinatra'
require_relative 'controllers/importer_controller'
require_relative 'db/redis_client'
require_relative 'db/local_keystore'
require_relative 'helpers/utils'
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

use ImporterController

# keystore = RedisClient.new(ENV['REDIS_URL'], ENV['REDIS_USERNAME'], ENV['REDIS_PASSWORD'])
keystore = LocalKeystore.instance

# post '/stop' do
#   import_id = params[:id]
#   content_type :json
#   return { error: 'Import ID required' }.to_json unless import_id

#   importer = keystore.get(import_id)
#   status 404 unless importer
#   return { error: 'Import ID not found' }.to_json unless importer

#   keystore.set("#{import_id}-stop", true)

#   { message: 'stopping', import_id: import_id }.to_json
# end
