class Detector
  class SuggestedResourcePhrase < ApplicationRecord
    before_save :update_fingerprint

    belongs_to :detector_suggested_resource, class_name: 'Detector:SuggestedResource'

    def self.table_name_prefix
      'detector_'
    end

    # This exists for the before_save lifecycle hook to call the calculate_fingerprint method, to ensure that these
    # records always have a correctly-calculated fingerprint. It has no arguments and returns nothing.
    def update_fingerprint
      self.fingerprint = SuggestedResource::Phrase.calculate_fingerprint(phrase)
    end

    # This implements the OpenRefine fingerprinting algorithm. See
    # https://openrefine.org/docs/technical-reference/clustering-in-depth#fingerprint
    #
    # @param old_phrase [String] A text string which needs to have its fingerprint calculated. This could either be the
    #   "phrase" field on the SuggestedResource record, or an incoming search term received from a contributing system.
    #
    # @return [String] A string of all words in the input, downcased, normalized, and alphabetized.
    def self.calculate_fingerprint(old_phrase)
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
