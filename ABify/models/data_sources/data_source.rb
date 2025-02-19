# frozen_string_literal: true

# Base class for data sources
# There can be multiple data sources, each with their own implementation
class DataSource
  # Placeholder method to be handled by subclasses
  def rows
    raise NotImplementedError, 'Subclasses must implement a rows method'
  end

  def summary(data: false, original_data: false)
    if data || original_data
      @rows.map { |row| row.summary(data: data, original_data: original_data) }
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
end
