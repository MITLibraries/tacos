# == Schema Information
#
# Table name: detector_suggested_resources
#
#  id          :integer          not null, primary key
#  title       :string
#  url         :string
#  phrase      :string
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'stringex/core_ext'

class Detector::SuggestedResource < ApplicationRecord
  before_save :update_fingerprint

  def update_fingerprint
    self.fingerprint = calculate_fingerprint
  end

  # This implements the OpenRefine fingerprinting algorithm. See
  # https://openrefine.org/docs/technical-reference/clustering-in-depth#fingerprint
  def calculate_fingerprint
    temp = self.phrase
    temp.strip!
    temp.downcase!

    # This removes all punctuation and symbol characters from the string.
    temp.gsub!(/\p{P}|\p{S}/, '')

    # Normalize to ASCII (e.g. gödel and godel are liable to be intended to
    # find the same thing)
    temp = temp.to_ascii

    # Coercion to ASCII can introduce new symbols, so we remove those now.
    temp.gsub!(/\p{P}|\p{S}/, '')

    # Tokenize
    array = temp.split

    # Remove duplicates and sort
    array.uniq!
    array.sort!

    # Rejoin tokens
    new_fingerprint = array.join(' ')
  end
end
