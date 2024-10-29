# frozen_string_literal: true

require 'csv'
require 'json'

# CSVWriter writes data to a CSV file
# TODO clean this up later with the logic from the Apps Script code
class CSVWriter
  def initialize(import_id)
    @import_id = import_id
    @file_path = "out/#{import_id}.csv"
  end

  def write_import_results(results)
    headers = ['Status']
    response_steps = gather_response_steps(results[:data])
    headers.concat(response_steps.map { |step| "Response (#{step})" })
    data_keys = gather_data_keys(results[:data])
    headers.concat(data_keys)

    CSV.open(@file_path, 'w') do |csv|
      csv << headers
      results[:data].each do |row|
        csv << build_row(headers, row, response_steps)
      end
    end
  end

  private

  def gather_response_steps(data)
    response_steps = data.flat_map do |row|
      row[:responses].map { |response| response[:step] }
    end
    error_steps = data.flat_map do |row|
      row[:errors].map { |error| error[:step] }
    end
    (response_steps + error_steps).uniq
  end

  def gather_data_keys(data)
    data.flat_map { |row| row[:data].keys }.uniq
  end

  def build_row(headers, row, response_steps)
    row_data = row[:data].dup
    status = row[:errors].empty? ? 'Success' : 'Error'
    row_data['Status'] = status

    response_steps.each do |step|
      error = row[:errors].find { |e| e[:step] == step }
      response = row[:responses].find { |r| r[:step] == step }
      if error
        error_text = error[:text].join('\n') if error[:text]
        row_data["Response (#{step})"] = "(#{error[:code]}) #{error_text}"
      elsif response
        row_data["Response (#{step})"] = response[:text]
      end
    end

    headers.map { |header| row_data[header] }
  end
end
