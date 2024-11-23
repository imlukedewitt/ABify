# frozen_string_literal: true

require_relative '../../db/redis_keystore'

# A row of data from a data source
class Row
  attr_accessor :data, :status, :errors, :requests, :responses, :index

  def initialize(data, index = nil)
    @data = data
    @index = index
    @status = nil
    @errors = []
    @requests = []
    @responses = []
  end

  def summary(data: false)
    summary = {
      index: @index,
      status: @status,
      errors: @errors,
      requests: @requests,
      responses: @responses
    }
    summary[:data] = @data if data
    summary
  end

  def update_keystore(import_id)
    address = "#{import_id}:#{@index}"
    keystore.set(address, summary(data: true))
  end

  private

  def keystore
    @keystore ||= RedisKeystore.instance
  end
end
