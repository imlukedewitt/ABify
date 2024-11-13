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
    expect(last_response.body).to eq({ message: 'started', import_id: '123' }.to_json)
    expect(Importer).to have_received(:new).once
    expect(importer_double).to have_received(:start).once
    expect(MockData).to have_received(:new).once
    expect(BuildWorkflow).to have_received(:for).once
  end

  it 'returns error for missing row count with mock data' do
    headers = http_headers.except('HTTP_ROW_COUNT')

    post '/start', {}, headers

    expect(last_response.status).to eq(422)
    expect(last_response.body).to include('Row count required for mock data')
  end

  it 'returns error for invalid source type' do
    headers = http_headers.merge('HTTP_SOURCE_TYPE' => 'invalid')

    post '/start', {}, headers

    expect(last_response.status).to eq(422)
    expect(last_response.body).to include('Invalid source type')
  end

  it 'returns error when loading CSV fails' do
    allow(CsvData).to receive(:new).and_raise(StandardError, 'CSV load error')
    headers = http_headers.merge('HTTP_SOURCE_TYPE' => 'csv')

    post '/start', {}, headers

    expect(last_response.status).to eq(422)
    expect(last_response.body).to include('Error loading CSV: CSV load error')
  end

  it 'returns the import status' do
    time = Time.now
    allow(LocalKeystore.instance).to receive(:get).and_return(
      {
        id: '123',
        status: 'complete',
        created_at: time,
        completed_at: time
      }
    )

    get '/status', { id: '123' }

    expect(last_response).to be_ok
  end
end
