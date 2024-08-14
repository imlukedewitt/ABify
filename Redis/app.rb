# frozen_string_literal: true

require 'json'
require 'redis'
require 'sinatra'
require 'dotenv'

# sinatra setup
set :bind, '0.0.0.0'
port = ENV['PORT'] || '4567'
set :port, port
enable :sessions
set :session_store, Rack::Session::Pool

# use dotenv for local testing
Dotenv.load('config/.env') unless ENV['RUNNING_ON_SERVER']

# basic auth
use Rack::Auth::Basic, 'Restricted Area' do |username, password|
  username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
end

# redis setup
redis_host = ENV['REDIS_HOST'] || 'localhost'
redis_port = ENV['REDIS_PORT'] || 6379
redis = Redis.new(host: redis_host, port: redis_port)

get '/' do
  'It works!'
end

post '/set' do
  data = JSON.parse(request.body.read)
  key = data['key']
  value = data['value'].to_json
  redis.set(key, value)
  status(201)
end

get '/get' do
  key = params['key']
  value = redis.get(key)
  content_type :json
  status(404) && return if value.nil?

  data = JSON.parse(value)
  data['run_time'] = update_run_time(data) unless data['completed_at']
  data.to_json
end

post '/del' do
  key = params['key']
  redis.del(key)
  status(204)
end

def update_run_time(data)
  start_time = Time.parse(data['created_at'])
  end_time = Time.now
  duration_in_seconds = end_time - start_time
  
  seconds = duration_in_seconds % 60
  minutes = (duration_in_seconds / 60) % 60
  hours = (duration_in_seconds / 3600)

  "#{hours.to_i}h #{minutes.to_i}m #{seconds.round(2)}s"
end