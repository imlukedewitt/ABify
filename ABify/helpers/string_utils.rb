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
end
