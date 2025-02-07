# frozen_string_literal: true

require 'stringex/core_ext'

class Detector
  # Detector::SuggestedResource handles detections for SuggestedResource records.
  class SuggestedResource
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
      ::SuggestedResource.joins(:fingerprints).where(fingerprints: { value: Fingerprint.calculate(phrase) })
    end

    # Look up any matching Detector::SuggestedResource records, building on the full_term_match method. If a match is
    # found, a Detection record is created to indicate this success.
    #
    # @note Multiple matches with Detector::SuggestedResource are not possible due to internal constraints in that
    #       detector, which requires a unique fingerprint for every record.
    #
    # @note Multiple detections are irrelevant for this method. If _any_ match is found, a Detection record is created.
    #       The uniqueness contraint on Detection records would make multiple detections irrelevant.
    #
    # @return nil
    def self.record(term)
      result = full_term_match(term.phrase)
      return unless result.any?

      Detection.find_or_create_by(
        term:,
        detector: Detector.where(name: 'SuggestedResource').first,
        detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
      )

      nil
    end
  end
end
