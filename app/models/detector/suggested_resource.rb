# frozen_string_literal: true

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

module Detector
  # Detector::SuggestedResource stores custom hints that we want to send to the
  # user in response to specific strings. For example, a search for "web of
  # science" should be met with our custom login link to Web of Science via MIT.
  class SuggestedResource < ApplicationRecord
    before_save :update_fingerprint

    def update_fingerprint
      self.fingerprint = calculate_fingerprint(phrase)
    end

    # This implements the OpenRefine fingerprinting algorithm. See
    # https://openrefine.org/docs/technical-reference/clustering-in-depth#fingerprint
    def calculate_fingerprint(old_phrase)
      modified_phrase = old_phrase
      modified_phrase = modified_phrase.strip
      modified_phrase = modified_phrase.downcase

      # This removes all punctuation and symbol characters from the string.
      modified_phrase = modified_phrase.gsub(/\p{P}|\p{S}/, '')

      # Normalize to ASCII (e.g. gödel and godel are liable to be intended to
      # find the same thing)
      modified_phrase = modified_phrase.to_ascii

      # Coercion to ASCII can introduce new symbols, so we remove those now.
      modified_phrase = modified_phrase.gsub(/\p{P}|\p{S}/, '')

      # Tokenize
      tokens = modified_phrase.split

      # Remove duplicates and sort
      tokens = tokens.uniq
      tokens = tokens.sort

      # Rejoin tokens
      tokens.join(' ')
    end
  end
end
