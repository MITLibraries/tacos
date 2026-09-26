# frozen_string_literal: true

class RegexValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    begin
      Regexp.new(value)
    rescue RegexpError
      record.errors.add(attribute, 'is not a valid regular expression')
    end
  end
end
