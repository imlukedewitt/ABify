# frozen_string_literal: true

require_relative 'data_source'
require_relative 'row'
require 'csv'

# data source from csv
class CsvData < DataSource
  attr_reader :rows

  def initialize(source)
    super()
    load_from_csv(source)
  end

  def load_from_csv(source)
    @rows = []
    index = 1

    if source.is_a?(IO) || source.is_a?(Tempfile)
      csv_enum = CSV.new(
        source,
        headers: true,
        encoding: 'utf-8',
        header_converters: ->(h) { h.downcase.strip }
      )
      csv_enum.each do |row_data|
        @rows << Row.new(row_data.to_h, index)
        index += 1
      end
      source.rewind if source.respond_to?(:rewind)
    else
      CSV.foreach(
        source,
        headers: true,
        encoding: 'utf-8',
        header_converters: ->(h) { h.downcase.strip }
      ) do |row_data|
        @rows << Row.new(row_data.to_h, index)
        index += 1
      end
    end
  end
end
