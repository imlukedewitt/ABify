# frozen_string_literal: true

require 'rack/test'
require_relative '../spec_helper'
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

  it 'starts an import with a CSV file upload' do
    csv_tempfile = Tempfile.new('test.csv')
    csv_tempfile.write("header1,header2\nvalue1,value2\n")
    csv_tempfile.rewind

    headers = http_headers.merge('HTTP_SOURCE_TYPE' => 'csv')
    file = Rack::Test::UploadedFile.new(csv_tempfile.path, 'text/csv')

    allow(CsvData).to receive(:new).and_return(instance_double('CsvData'))

    post '/start', { file: file }, headers

    expect(last_response).to be_ok
    expect(Importer).to have_received(:new).once
    expect(CsvData).to have_received(:new).once

    csv_tempfile.close
    csv_tempfile.unlink
  end

  it 'starts an import with a JSON file upload' do
    json_tempfile = Tempfile.new('test.json')
    json_tempfile.write('[{"foo":"bar"}]')
    json_tempfile.rewind

    headers = http_headers.merge('HTTP_SOURCE_TYPE' => 'json')
    file = Rack::Test::UploadedFile.new(json_tempfile.path, 'application/json')

    allow(JsonData).to receive(:new).and_return(instance_double('JsonData'))

    post '/start', { file: file }, headers

    expect(last_response).to be_ok
    expect(Importer).to have_received(:new).once
    expect(JsonData).to have_received(:new).once

    json_tempfile.close
    json_tempfile.unlink
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
    body = JSON.parse(last_response.body)
    expect(body['id']).to eq('123')
    expect(body['status']).to eq('complete')
    expect(body['run_time']).to eq('0h 0m 0.0s')
  end

  it 'returns error for missing import id' do
    get '/status'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to include('Import ID required')
  end

  it 'returns error for missing import data' do
    get '/status', { id: '123' }

    expect(last_response.status).to eq(404)
    expect(last_response.body).to include('Import ID not found')
  end

  it 'it stops an import' do
    allow(LocalKeystore.instance).to receive(:set)
    allow(LocalKeystore.instance).to receive(:get).and_return({ id: '123' })

    post '/stop', { id: '123' }

    expect(last_response).to be_ok
    expect(LocalKeystore.instance).to have_received(:set).with('123-stop', true)
  end
end
