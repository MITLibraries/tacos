# frozen_string_literal: true

class Detector
  # PatternChecker is intended to be added to Detectors via `include Detector::PatternChecker` to make
  # these methods available to instances of the class
  # See also: `BulkTermChecker` for shared singleton methods
  module PatternChecker
    # pattern_checker iterates over all patterns defined in the calling object's `pattern` method.
    #
    #   @param phrase [String]. Often a `Term.phrase`.
    #   @return Nothing intentional. Data is written to Hash `@detections` during processing.
    def pattern_checker(phrase)
      patterns.each_pair do |type, pattern|
        @detections[type.to_sym] = match(pattern, phrase) if match(pattern, phrase).present?
      end
    end

    # Note on the limitations of this implementation
    # We only detect the first match of each pattern, so a search of "1234-5678 5678-1234" will not return two ISSNs as
    # might be expected, but just "1234-5678". Using ruby's string.scan(pattern) may be worthwhile if we want to detect
    # all possible matches instead of just the first. That may require a larger refactor though as initial tests of doing
    # that change did result in unintended results so it was backed out for now.
    #
    #   @param pattern Regexp
    #   @param phrase String. Often a `Term.phrase`.
    #
    #   @return String
    def match(pattern, phrase)
      pattern.match(phrase).to_s.strip
    end
  end
end
