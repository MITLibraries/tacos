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

class Detector
  # Detector::SuggestedResource stores custom hints that we want to send to the
  # user in response to specific strings. For example, a search for "web of
  # science" should be met with our custom login link to Web of Science via MIT.
  class SuggestedResource < ApplicationRecord
    before_save :update_fingerprint

    def self.table_name_prefix
      'detector_'
    end

    # This exists for the before_save lifecycle hook to call the calculate_fingerprint method, to ensure that these
    # records always have a correctly-calculated fingerprint. It has no arguments and returns nothing.
    def update_fingerprint
      self.fingerprint = Detector::SuggestedResource.calculate_fingerprint(phrase)
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

    # This replaces all current Detector::SuggestedResource records with a new set from an imported CSV.
    #
    # @note This method is called by the suggested_resource:reload rake task.
    #
    # @param input [CSV::Table] An imported CSV file containing all Suggested Resource records. The CSV file must have
    #                           at least three headers, named "Title", "URL", and "Phrase". Please note: these values
    #                           are case sensitive.
    def self.bulk_replace(input)
      raise ArgumentError.new, 'Tabular CSV is required' unless input.instance_of?(CSV::Table)

      # Need to check what columns exist in input
      required_headers = %w[Title URL Phrase]
      missing_headers = required_headers - input.headers
      raise ArgumentError.new, "Some CSV columns missing: #{missing_headers}" unless missing_headers.empty?

      Detector::SuggestedResource.delete_all

      input.each do |line|
        record = Detector::SuggestedResource.new({ title: line['Title'], url: line['URL'], phrase: line['Phrase'] })
        record.save
      end
    end

    # Identify any SuggestedResource record whose pre-calculated fingerprint matches the fingerprint of the incoming
    # phrase.
    #
    # @note There is a uniqueness constraint on the SuggestedResource fingerprint field, so there should only ever be
    #   one match (if any).
    #
    # @param phrase [String]. A string representation of a searchterm (not an actual Term object)
    #
    # @return [Detector::SuggestedResource] The record whose fingerprint matches that of the search term.
    def self.full_term_match(phrase)
      SuggestedResource.where(fingerprint: calculate_fingerprint(phrase))
    end
  end
end
