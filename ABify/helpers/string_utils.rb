# frozen_string_literal: true

# Module to handle string operations
module StringUtils
  def true?(value)
    value.to_s.downcase == 'true'
  end

  def false?(value)
    !true?(value)
  end

  def blank?(value)
    value.nil? || value.to_s.strip.empty?
  end

  def present?(value)
    !blank?(value)
  end

  def generate_id
    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    unique_id = SecureRandom.hex(4)
    "#{timestamp}-#{@config.subdomain}-#{unique_id}"
  end
end
