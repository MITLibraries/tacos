# frozen_string_literal: true

class Detector
  # Detector::SuggestedResourcePattern handles detections for SuggestedResources based on patterns stored in our
  # SuggestedPattern model
  class SuggestedResourcePattern
    attr_reader :detections

    # shared singleton methods
    extend Detector::BulkChecker

    def initialize(phrase)
      @detections = {}
      check_patterns(phrase)
    end

    # check_patterns loops through all stored patterns from SuggestedPattern model, checks to see if they produce
    # matches for the incoming `phrase`, and if so creates a Hash with useful data
    #
    # @note Not using shared PatternChecker as we want to include additional data in the returned object
    # @param phrase [String]. A string representation of a searchterm (not an actual Term object)
    # @return primarily intended to add matches to @detections
    def check_patterns(phrase)
      sps = []
      SuggestedPattern.find_each do |sp|
        next unless Regexp.new(sp.pattern).match(phrase)

        sps << {
          shortcode: sp.shortcode,
          title: sp.title,
          url: sp.url
        }
        @detections = sps
      end
    end

    # The record method will consult the set of regex-based detectors that are defined in
    # SuggestedPattern records. Any matches will be registered as Detection records.
    #
    # @note There are multiple patterns within SuggestedPattern records. Each check is capable of generating
    #       a separate Detection record.
    #
    # @return nil
    def self.record(term)
      sp = Detector::SuggestedResourcePattern.new(term.phrase)

      sp.detections.each do
        Detection.find_or_create_by(
          term:,
          detector: Detector.where(name: 'SuggestedResourcePattern').first,
          detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
        )
      end

      nil
    end
  end
end
