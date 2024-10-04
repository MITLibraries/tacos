# frozen_string_literal: true

class Detector
  # Detector::LCSH is a very rudimentary detector for the separator between levels of a Library of Congress Subject
  # Heading (LCSH). These subject headings follow this pattern: "Social security beneficiaries -- United States"
  class Lcsh
    attr_reader :identifiers

    # For now the initialize method just needs to run the pattern checker. A space for future development would be to
    # write additional methods to look up the detected LCSH for more information, and to confirm that the phrase is
    # actually an LCSH.
    def initialize(term)
      @identifiers = {}
      term_pattern_checker(term)
    end

    # The record method will consult the set of regex-based detectors that are defined in Detector::Lcsh. Any matches
    # will be registered as Detection records.
    #
    # @note While there is currently only one check within the Detector::Lcsh class, the method is build to anticipate
    #       additional checks in the future. Every such check would be capable of generating a separate Detection record
    #       (although a single check finding multiple matches would still only result in one Detection).
    #
    # @return nil
    def self.record(term)
      results = Detector::Lcsh.new(term.phrase)

      results.identifiers.each_key do
        Detection.find_or_create_by(
          term:,
          detector: Detector.where(name: 'LCSH').first,
          detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
        )
      end

      nil
    end

    private

    def term_pattern_checker(term)
      subject_patterns.each_pair do |type, pattern|
        @identifiers[type.to_sym] = match(pattern, term) if match(pattern, term).present?
      end
    end

    # This implementation will only detect the first match of a pattern in a long string. For the separator pattern this
    # is fine, as we only need to find one (and finding multiples wouldn't change the outcome). If a pattern does come
    # along where match counts matter, this should be reconsidered.
    def match(pattern, term)
      pattern.match(term).to_s.strip
    end

    # subject_patterns are regex patterns that can be applied to indicate whether a search string is looking for an LCSH
    # string. At the moment there is only one - for the separator character " -- " - but others might be possible if
    # there are regex-able vocabulary quirks which might separate subject values from non-subject values.
    def subject_patterns
      {
        separator: /(.*)\s--\s(.*)/
      }
    end
  end
end
