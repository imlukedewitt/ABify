# frozen_string_literal: true

require_relative 'data_source'
require_relative 'row'
require 'json'

# Data source from JSON
class JsonData < DataSource
  attr_reader :rows

  def initialize(source)
    super()
    load_from_json_source(source)
  end

  def load_from_json_source(source)
    json_string =
      if source.is_a?(IO) || source.is_a?(Tempfile)
        source.rewind if source.respond_to?(:rewind)
        source.read
      elsif File.exist?(source.to_s)
        File.read(source)
      else
        source.to_s
      end

    data_array = JSON.parse(json_string)
    @rows = data_array.map.with_index(1) do |row_data, idx|
      row = Row.new(row_data, row_data['index'] || idx)
      row
    end
  end
end
