# frozen_string_literal: true

# Base class for data sources
# There can be multiple data sources, each with their own implementation
class DataSource
  attr_reader :original_data

  # Placeholder method to be handled by subclasses
  def rows
    raise NotImplementedError, 'Subclasses must implement a rows method'
  end

  def summary(data: false)
    if data
      @rows.map { |row| row.summary(data: data) }
    else
      @rows.select { |row| row.requests.length > 1 }.map { |row| row.summary(data: data) }
    end
  end

  def completed_row_count
    @rows.select { |row| %w[complete error].include?(row.status) }.count
  end

  def failed_row_count
    @rows.select { |row| row.status == 'error' }.count
  end

  protected

  def store_original_data
    @original_data = summary(data: true)
  end
end
