# frozen_string_literal: true

require_relative 'data_source'
require_relative 'row'
require 'json'

# Data source from JSON file
class JsonFileSource < DataSource
  attr_reader :rows

  def initialize(file_path)
    super()
    load_from_file(file_path)
  end

  def load_from_file(file_path)
    raise ArgumentError, 'File does not exist' unless File.exist?(file_path)

    json_string = File.read(file_path)
    data_array = JSON.parse(json_string)
    @rows = data_array.map.with_index(1) do |row_data, idx|
      row = Row.new(row_data, row_data['index'] || idx)
      row
    end
  end
end
