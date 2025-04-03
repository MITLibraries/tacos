# frozen_string_literal: true

class Detector
  # BulkTermChecker is expected to be added to Detectors via `extend Detector::BulkTermChecker` to allow the
  # singleton class to access it
  # See also: `PatternChecker` for shared instance methods
  module BulkChecker
    # This method is intended to be used for inspecting detections during development.
    # Assumptions include
    #   - the Class including this module implements a `detections` method (either via `attr_reader` or as a method)
    #     that is only populated for Terms in which it has made a detection
    #   - the initialize method accepts a `phrase` as a string
    # @param output [boolean] optional. Defaults to false as that is the more likely scenario useful in development as
    #   the logger output is often what is desired.
    def check_all_matches(output: false)
      count = 0
      matches = []
      Term.find_each do |t|
        d = new(t.phrase)
        next if d.detections.blank?

        count += 1

        matches.push [t.phrase, d.detections]
      end

      log_summary(matches) if Rails.env.development?

      matches if output
    end

    def log_summary(matches)
      Rails.logger.info(ap(matches))

      Rails.logger.info "Total Terms  : #{Term.count}"
      Rails.logger.info "Total Matches: #{matches.count}"
    end
  end
end
