# frozen_string_literal: true

require_relative 'data_source'
require_relative 'row'
require 'json'

# Data source from JSON
class JsonData < DataSource
  attr_reader :rows

  def initialize(data)
    super()
    load_from_json(data)
  end

  def load_from_json(json_string)
    data_array = JSON.parse(json_string)
    @rows = data_array.map.with_index(1) do |row_data, idx|
      row = Row.new(row_data, row_data['index'] || idx)
      row
    end
  end
end
