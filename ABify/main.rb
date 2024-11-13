# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'pry'
require 'sinatra'
require_relative 'controllers/importer_controller'

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
