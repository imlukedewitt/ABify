# frozen_string_literal: true

require 'csv'
require_relative '../spec_helper'
require_relative '../../helpers/csv_writer'

RSpec.describe CSVWriter do
  let(:import_id) { 'test-import' }
  let(:csv_writer) { CSVWriter.new(import_id) }
  let(:results) do
    {
      id: '20250112143824-luke-test-import',
      status: 'complete',
      created_at: '2025-01-12 14:38:24 +0000',
      completed_at: '2025-01-12 14:38:24 +0000',
      run_time: '0h 0m 0.46s',
      row_count: 1,
      completed_rows: 1,
      failed_rows: 0,
      subdomain: 'luke',
      domain: 'chargify.com',
      data: [
        {
          index: 1,
          status: 'complete',
          errors: [],
          requests: [
            {
              step: 'create customer',
              url: 'https://site.app.com/customers.json',
              method: 'post',
              body: {
                customer: {
                  first_name: 'Jon',
                  last_name: 'Jon',
                  email: 'jon@jon.example'
                }
              }
            }
          ],
          responses: [
            {
              step: 'create customer',
              text: 'https://site.app.com/customers/12345',
              key: 'customer id',
              value: 12345
            }
          ],
          data: {
            "first name": 'Jon',
            "last name": 'Jon',
            "email": 'test@example.com',
            "customer id": 12345
          }
        }
      ]
    }
  end

  it 'sets the file path' do
    expect(csv_writer.instance_variable_get(:@file_path)).to eq('out/test-import.csv')
  end

  it 'writes the import results to a CSV file' do
    csv_mock = double('CSV')
    allow(CSV).to receive(:open).and_yield(csv_mock)
    expect(csv_mock).to receive(:<<).with(
      ['Status', 'Response (create customer)', :'first name', :'last name', :email, :'customer id']
    )
    expect(csv_mock).to receive(:<<).with(
      ['Success', 'https://site.app.com/customers/12345', 'Jon', 'Jon', 'test@example.com', 12345]
    )

    csv_writer.write_import_results(results)
  end
end
