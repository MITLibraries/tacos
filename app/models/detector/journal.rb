# frozen_string_literal: true

class Detector
  # Detector::Journal handles the comparison between incoming Term records and our known list of academic journals
  # (which are managed by the separate Journal model).
  class Journal
    attr_reader :detections

    # shared singleton methods
    extend Detector::BulkChecker

    def initialize(phrase)
      @detections = Detector::Journal.full_term_match(phrase)
    end

    # Identify journals in which the incoming phrase matches a Journal.name exactly
    #
    # @note We always store the Journal.name downcased, so we should also always downcase the phrase
    #   when matching
    #
    # @note In reality, multiple Journals can exist with the same name. Therefore, we don't enforce
    #   unique names and don't expect a single Journal to be returned.
    #
    # @param phrase [String]. A string representation of a search term (not an actual Term object!)
    #
    # @return [Set of Journal] A set of ActiveRecord Journal records.
    def self.full_term_match(phrase)
      ::Journal.where(name: phrase.downcase)
    end

    # Identify journals in which the incoming phrase contains one or more Journal names
    #
    # @note This likely won't scale well and may not be suitable for live detection as it loads all Journal records.
    #
    # @param phrase [String]. A string representation of a search term (not an actual Term object!)
    #
    # @return [Set of Journal] A set of ActiveRecord Journal records.
    def self.partial_term_match(phrase)
      ::Journal.all.select { |journal| phrase.downcase.include?(journal.name) }
    end

    # Look up any matching Journal records, building on the full_term_match method. If a match is found, a
    # Detection record is created to indicate this success.
    #
    # @note This does not care whether multiple matching journals are detected. If _any_ match is found, a Detection
    #       record is created. The uniqueness constraint on Detection records would make multiple detections irrelevant.
    #
    # @return nil
    def self.record(term)
      result = full_term_match(term.phrase)
      return unless result.any?

      Detection.find_or_create_by(
        term:,
        detector: Detector.where(name: 'Journal').first,
        detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
      )

      result
    end
  end
end
