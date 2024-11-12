# frozen_string_literal: true

require 'sinatra/base'

# ImporterController
class ImporterController < Sinatra::Base
  get '/' do
    return 'It works!'
  end
end
