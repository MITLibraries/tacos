# frozen_string_literal: true

class Detector
  # PatternChecker is intended to be added to Detectors via `include Detector::PatternChecker` to make
  # these methods available to instances of the class
  module PatternChecker
    def term_pattern_checker(term)
      term_patterns.each_pair do |type, pattern|
        @detections[type.to_sym] = match(pattern, term) if match(pattern, term).present?
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
  end
end
