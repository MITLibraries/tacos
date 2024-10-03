# frozen_string_literal: true

class Detector
  # Detector::StandardIdentifiers detects the identifiers DOI, ISBN, ISSN, PMID.
  # See /docs/reference/pattern_detection_and_enhancement.md for details.
  class StandardIdentifiers
    attr_reader :identifiers

    def self.table_name_prefix
      'detector_'
    end

    def initialize(term)
      @identifiers = {}
      term_pattern_checker(term)
      strip_invalid_issns
    end

    # The record method will consult the set of regex-based detectors that are defined in
    # Detector::StandardIdentifiers. Any matches will be registered as Detection records.
    #
    # @note There are multiple checks within the Detector::StandardIdentifier class. Each check is capable of generating
    #       a separate Detection record (although a single check finding multiple matches would still only result in one
    #       Detection for that check).
    #
    # @return nil
    def self.record(term)
      si = Detector::StandardIdentifiers.new(term.phrase)

      si.identifiers.each_key do |k|
        Detection.find_or_create_by(
          term:,
          detector: Detector.where(name: k.to_s.upcase).first,
          detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
        )
      end

      nil
    end

    private

    def term_pattern_checker(term)
      term_patterns.each_pair do |type, pattern|
        @identifiers[type.to_sym] = match(pattern, term) if match(pattern, term).present?
      end
    end

    # Note on the limitations of this implementation
    # We only detect the first match of each pattern, so a search of "1234-5678 5678-1234" will not return two ISSNs as
    # might be expected, but just "1234-5678". Using ruby's string.scan(pattern) may be worthwhile if we want to detect
    # all possible matches instead of just the first. That may require a larger refactor though as initial tests of doing
    # that change did result in unintended results so it was backed out for now.
    def match(pattern, term)
      pattern.match(term).to_s.strip
    end

    # term_patterns are regex patterns to be applied to the basic search box input
    def term_patterns
      {
        isbn: /\b(ISBN-*(1[03])* *(: ){0,1})*(([0-9Xx][- ]*){13}|([0-9Xx][- ]*){10})\b/,
        issn: /\b[0-9]{4}-[0-9]{3}[0-9xX]\b/,
        pmid: /\b((pmid|PMID):\s?(\d{7,8}))\b/,
        doi: %r{\b10\.(\d+\.*)+/(([^\s.])+\.*)+\b}
      }
    end

    def strip_invalid_issns
      return unless @identifiers[:issn]

      @identifiers.delete(:issn) unless validate_issn(@identifiers[:issn])
    end

    # validate_issn is only called when the regex for an ISSN has indicated an ISSN
    # of sufficient format is present - but the regex does not attempt to
    # validate that the check digit in the ISSN spec is correct. This method
    # does that calculation, so we do not returned falsely detected ISSNs,
    # like "2015-2019".
    #
    # The algorithm is defined at
    # https://datatracker.ietf.org/doc/html/rfc3044#section-2.2
    # An example calculation is shared at
    # https://en.wikipedia.org/wiki/International_Standard_Serial_Number#Code_format
    def validate_issn(candidate)
      digits = candidate.delete('-')[..6].chars
      check_digit = candidate.last.downcase
      sum = 0

      digits.each_with_index do |digit, idx|
        sum += digit.to_i * (8 - idx.to_i)
      end

      actual_digit = 11 - sum.modulo(11)
      actual_digit = 'x' if actual_digit == 10

      return true if actual_digit.to_s == check_digit.to_s

      false
    end
  end
end
