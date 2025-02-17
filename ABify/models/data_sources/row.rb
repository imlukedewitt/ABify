# frozen_string_literal: true

# A row of data from a data source
class Row
  attr_accessor :data, :status, :errors, :requests, :responses, :index, :original_data

  def initialize(data, index = nil)
    @data = data
    @original_data = data
    @index = index
    @status = nil
    @errors = []
    @requests = []
    @responses = []
  end

  def summary(data: false, original_data: false)
    summary = {
      index: @index,
      status: @status,
      errors: @errors,
      requests: @requests,
      responses: @responses
    }
    summary[:data] = @data if data
    summary[:data] = @original_data if original_data
    summary
  end
end
