# frozen_string_literal: true

class Detector
  # Detector::StandardIdentifiers detects the identifiers Barcode, DOI, ISBN, ISSN, PMID.
  # See /docs/reference/pattern_detection_and_enhancement.md for details.
  class StandardIdentifiers
    attr_reader :detections

    def self.table_name_prefix
      'detector_'
    end

    # shared instance methods
    include Detector::PatternChecker

    # shared singleton methods
    extend Detector::BulkChecker

    # Initialization process will run pattern checkers and strip invalid ISSN detections.
    #
    # @param phrase String. Often a `Term.phrase`.
    # @return nil. Data is written to Hash `@detections` during processing. Things technically get
    #   returned here but it is a side effect and should not be relied on.
    def initialize(phrase)
      @detections = {}
      pattern_checker(phrase)
      strip_invalid_issns
      strip_invalid_isbns
      strip_pmid_prefix
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

      si.detections.each_key do |k|
        Detection.find_or_create_by(
          term:,
          detector: Detector.where(name: k.to_s.upcase).first,
          detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
        )
      end

      nil
    end

    private

    # patterns are regex patterns to be applied to the basic search box input
    def patterns
      {
        barcode: /^39080[0-9]{9}$/,
        isbn: /\b(([0-9Xx][- ]*){13}|([0-9Xx][- ]*){10})\b/,
        issn: /\b[0-9]{4}-[0-9]{3}[0-9xX]\b/,
        pmid: /\b((pmid|PMID):\s?(\d{7,8}))\b/,
        doi: %r{\b10\.(\d+\.*)+/(([^\s.])+\.*)+\b}
      }
    end

    # strip_pmid_prefix removes the PMID:/pmid: prefix from the detected value. The regex needs that, but the
    # actual value of the identifier should not include those prefixes.
    def strip_pmid_prefix
      @detections[:pmid] = @detections[:pmid].gsub(/pmid:|PMID:/, '').strip if @detections[:pmid].present?
    end

    # strip_invalid_isbns coordinates the logic to remove ISBNs that are not valid from our list of detected ISBNs
    #
    # ISBNs cannot be validated via regex. Regex gives us a list of candidates that look like ISBNs. We remove invalid
    # ISBNs by following validation specifications defined in the standard.
    def strip_invalid_isbns
      return unless @detections[:isbn]

      @detections.delete(:isbn) unless valid_isbn?(@detections[:isbn])
    end

    # valid_isbn? checks for 10 or 13 digit ISBNs and defers to appropriate methods for each
    #
    # @param candidate String. A string representation of a regex detected ISBN.
    # @return boolean
    def valid_isbn?(candidate)
      digits = candidate.delete('-').chars

      # check 10 digit
      if digits.length == 10
        valid_isbn_10?(digits)
      # check 13 digit
      elsif digits.length == 13
        valid_isbn_13?(digits)
      # This shouldn't happen, log an error.
      else
        Rails.logger.error("Non-10 or 13 digit sequence detected as ISBN: #{candidate}")
        Sentry.capture_message('Non-10 or 13 digit sequence detected as ISBN')
        false
      end
    end

    # valid_isbn_10? follows the ISBN 10 specification for validation
    # https://en.wikipedia.org/wiki/ISBN#ISBN-10_check_digits
    #
    # @param digits Array. An array of strings representing each character from a detected ISBN candidate.
    # @return boolean
    def valid_isbn_10?(digits)
      sum = 0
      digits.each_with_index do |digit, index|
        digit = '10' if digit.casecmp('x').zero?
        sum += digit.to_i * (10 - index)
      end
      (sum % 11).zero?
    end

    # valid_isbn_13? follows the ISBN 13 specification for validation
    # https://en.wikipedia.org/wiki/ISBN#ISBN-13_check_digit_calculation
    #
    # @param digits Array. An array of strings representing each character from a detected ISBN candidate.
    # @return boolean
    def valid_isbn_13?(digits)
      sum = 0
      digits.map(&:to_i).each_with_index do |digit, index|
        sum += digit * (index.even? ? 1 : 3)
      end

      (sum % 10).zero?
    end

    # strip_invalid_issns coordinates the logic to remove ISSNs that are not valid from our list of detected ISSNs
    #
    # ISSNs cannot be validated via regex. Regex gives us a list of candidates that look like ISSNs. We remove invalid
    # ISSNs by following validation specifications defined in the standard.
    def strip_invalid_issns
      return unless @detections[:issn]

      @detections.delete(:issn) unless validate_issn(@detections[:issn])
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
