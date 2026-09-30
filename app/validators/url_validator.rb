# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    begin
      parsed = URI.parse(value)
      record.errors.add(attribute, 'must use HTTP or HTTPS') unless parsed.is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      record.errors.add(attribute, 'is not a valid URL')
    end
  end
end
