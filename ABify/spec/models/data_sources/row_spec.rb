# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../models/data_sources/row'

RSpec.describe Row do
  let(:data) { { 'name' => 'Test User', 'email' => 'test@example.com' } }
  let(:index) { 1 }
  subject(:row) { described_class.new(data, index) }

  describe '#initialize' do
    it 'sets initial values' do
      expect(row.data).to eq(data)
      expect(row.original_data).to eq(data)
      expect(row.index).to eq(index)
      expect(row.status).to be_nil
      expect(row.errors).to be_empty
      expect(row.requests).to be_empty
      expect(row.responses).to be_empty
    end
  end

  describe '#summary' do
    before do
      row.status = 'completed'
      row.errors << 'Test error'
      row.requests << 'GET /test'
      row.responses << '200 OK'
    end

    it 'returns basic summary without data by default' do
      summary = row.summary

      expect(summary[:index]).to eq(index)
      expect(summary[:status]).to eq('completed')
      expect(summary[:errors]).to eq(['Test error'])
      expect(summary[:requests]).to eq(['GET /test'])
      expect(summary[:responses]).to eq(['200 OK'])
      expect(summary[:data]).to be_nil
    end

    it 'includes current data when data option is true' do
      summary = row.summary(data: true)
      expect(summary[:data]).to eq(data)
    end

    it 'includes original data when original_data option is true' do
      row.data['name'] = 'New Name'
      summary = row.summary(original_data: true)
      expect(summary[:data]).to eq({ 'name' => 'Test User', 'email' => 'test@example.com' })
      expect(row.data['name']).to eq('New Name')
      expect(row.original_data['name']).to eq('Test User')
    end
  end
end
