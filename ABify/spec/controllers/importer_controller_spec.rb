# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../controllers/importer_controller'
require_relative '../../models/importer'
require_relative '../../workflows/build_workflow'
require_relative '../../models/data_sources/mock_data_source'
require_relative '../../models/data_sources/csv_source'
require_relative '../../models/data_sources/json_source'

RSpec.describe ImporterController do
  include Rack::Test::Methods

  def app
    described_class.new
  end

  let(:importer_double) { instance_double('Importer', start: nil, id: '123') }
  let(:http_headers) do
    {
      'HTTP_APIKEY' => '123',
      'HTTP_SUBDOMAIN' => 'test',
      'HTTP_DOMAIN' => 'com',
      'HTTP_TEMPLATE' => 'test-template',
      'HTTP_SOURCE_TYPE' => 'mock',
      'HTTP_ROW_COUNT' => '1'
    }
  end

  before do
    allow(BuildWorkflow).to receive(:for).and_return(instance_double('Workflow'))
    allow(MockData).to receive(:new).and_return(instance_double('MockData'))
    allow(CsvData).to receive(:new).and_return(instance_double('CsvData'))
    allow(JsonData).to receive(:new).and_return(instance_double('JsonData'))
    allow(Thread).to receive(:new).and_yield
    allow(Importer).to receive(:new).and_return(importer_double)
  end

  it 'responses to requests' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('It works!')
  end

  it 'starts an import with mock data' do
    post '/start', {}, http_headers

    expect(last_response).to be_ok

    expect(Importer).to have_received(:new).once
    expect(importer_double).to have_received(:start).once
    expect(MockData).to have_received(:new).once
    expect(BuildWorkflow).to have_received(:for).once
  end
end
