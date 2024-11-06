# frozen_string_literal: true

# Module for misc template helper functions
module Utils
  # recursively remove empty values from a payload
  def trim_payload(hash)
    hash.each_with_object({}) do |(k, v), new_hash|
      cleaned_value = v.is_a?(Hash) ? trim_payload(v) : v

      next if cleaned_value.nil? || cleaned_value.to_s.strip == '' || cleaned_value == [] || cleaned_value == {}

      new_hash[k] = cleaned_value
    end
  end

  def duration(start_time, end_time)
    return nil unless start_time

    end_time = Time.now if end_time.nil?
    duration_in_seconds = end_time - start_time

    seconds = duration_in_seconds % 60
    minutes = (duration_in_seconds / 60) % 60
    hours = (duration_in_seconds / 3600)

    "#{hours.to_i}h #{minutes.to_i}m #{seconds.round(2)}s"
  end
end
