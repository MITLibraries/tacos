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
    has_many :detector_suggested_resource_phrases, class_name: 'Detector::SuggestedResourcePhrase'

    def self.table_name_prefix
      'detector_'
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
        record = Detector::SuggestedResource.find_or_create_by(title: line['title'], url: line['url'])
        record.detector_suggested_resource_phrases.find_or_create_by(phrase: line['Phrase'])
      end
    end

    # Identify any SuggestedResource record whose pre-calculated fingerprint matches the fingerprint of the incoming
    # phrase.
    #
    # @note There is a uniqueness constraint on the SuggestedResource fingerprint field, so there should only ever be
    #   one match (if any).
    #
    # @param search_phrase [String]. A string representation of a searchterm (not an actual Term object)
    #
    # @return [Detector::SuggestedResource] The record whose fingerprint matches that of the search term.
    def self.full_term_matches(search_phrase)
      Detector::SuggestedResource.joins(:phrases).where(phrases: { fingerprint: calculate_fingerprint(search_phrase) })
    end
  end
end
