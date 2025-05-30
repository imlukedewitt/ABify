# frozen_string_literal: true

# Module for misc template helper functions
module Utils
  CRUSHABLE = [nil, [], {}, ""].freeze

  # recursively remove empty values from a payload
  # insprired by https://stackoverflow.com/a/65082546
  def trim_payload(obj)
    case obj
    when Hash
      obj.each_with_object({}) do |(k, v), new_hash|
        v = trim_payload(v)
        next if CRUSHABLE.include?(v) || (v.is_a?(String) && v.strip.empty?)

        new_hash[k] = v
      end
    when Array
      obj.map { |e| trim_payload(e) }
         .reject { |e| CRUSHABLE.include?(e) || (e.is_a?(String) && e.strip.empty?) }
    else
      obj
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
