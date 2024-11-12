# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../controllers/importer_controller'

RSpec.describe ImporterController do
  include Rack::Test::Methods

  def app
    described_class.new
  end

  it 'responses to requests' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('It works!')
  end

  it 'starts an import' do
    post '/start'

    expect(last_response).to be_ok
  end
end
