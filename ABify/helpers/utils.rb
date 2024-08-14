# frozen_string_literal: true

# Module for misc template helper functions
module Utils
  # recursively remove empty values from a payload
  def trim_payload(hash)
    hash.each_with_object({}) do |(k, v), new_hash|
      # Recursively clean sub-hashes
      cleaned_value = v.is_a?(Hash) ? trim_payload(v) : v

      # Skip nil, empty strings, empty arrays, and empty hashes
      next if cleaned_value.nil? || cleaned_value == '' || cleaned_value == [] || cleaned_value == {}

      new_hash[k] = cleaned_value
    end
  end
end
