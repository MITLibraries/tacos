# frozen_string_literal: true

# == Schema Information
#
# Table name: fingerprints
#
#  id          :integer          not null, primary key
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Fingerprint < ApplicationRecord
  has_many :terms, dependent: :nullify

  validates :fingerprint, uniqueness: true

  alias_attribute :fingerprint_value, :fingerprint

  # This is similar to the SuggestedResource fingerprint method, with the exception that it also replaces &quot; with "
  # during its operation. This switch may also need to be added to the SuggestedResource method, at which point they can
  # be abstracted to a helper method.
  def self.calculate(phrase)
    modified = phrase
    modified = modified.strip
    modified = modified.downcase
    modified = modified.gsub('&quot;', '"') # This line does not exist in SuggestedResource implementation.
    modified = modified.gsub(/\p{P}|\p{S}/, '')
    modified = modified.to_ascii
    modified = modified.gsub(/\p{P}|\p{S}/, '')
    tokens = modified.split
    tokens = tokens.uniq
    tokens = tokens.sort
    tokens.join(' ')
  end
end
