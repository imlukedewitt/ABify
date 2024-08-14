# frozen_string_literal: true

require_relative 'data_source'
require_relative 'row'
require 'csv'

# data source from csv
class CsvData < DataSource
  attr_reader :rows

  def initialize(file_path)
    super()
    load_from_csv(file_path)
  end

  def load_from_csv(file_path)
    @rows = []
    index = 1

    CSV.foreach(
      file_path,
      headers: true,
      encoding: 'utf-8',
      header_converters: ->(h) { h.downcase.strip }
    ) do |row_data|
      @rows << Row.new(row_data.to_h, index)
      index += 1
    end
  end
end
