# frozen_string_literal: true

# == Schema Information
#
# Table name: metrics_algorithms
#
#  id            :integer          not null, primary key
#  month         :date
#  doi           :integer
#  issn          :integer
#  isbn          :integer
#  pmid          :integer
#  unmatched     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  journal_exact :integer
#
module Metrics
  # Algorithms aggregates statistics for matches for all SearchEvents
  class Algorithms < ApplicationRecord
    self.table_name = 'metrics_algorithms'

    # generate metrics data about SearchEvents matches
    #
    # @note This is expected to only be run once per month per type of aggregation (once with no month supplied, once
    #   with a month supplied), ideally at the beginning of the following month to ensure as
    #   accurate as possible statistics. Running further from the month in question will work, but matches will use the
    #   current versions of all algorithms which may not match the algorithm in place during the month the SearchEvent
    #   occurred.
    # @note We don't currently prevent this running more than once per month per type of aggregation.
    # @param month [DateTime] A DateTime object within the `month` to be generated. Defaults to nil will runs is how
    #   total algorithm statistics are created.
    # @example
    #   # Generate metrics for all SearchEvents
    #   Metrics::Algorithms.new.generate
    #
    #   # Generate metrics for all SearchEvents last month
    #   Metrics::Algorithms.new.generate(1.month.ago)
    # @return [Metrics::Algorithms] The created Metrics::Algorithms object.
    def generate(month = nil)
      matches = if month.present?
                  count_matches(SearchEvent.single_month(month).includes(:term))
                else
                  count_matches(SearchEvent.includes(:term))
                end
      Metrics::Algorithms.create(month:, doi: matches[:doi], issn: matches[:issn], isbn: matches[:isbn],
                                 pmid: matches[:pmid], journal_exact: matches[:journal_exact],
                                 suggested_resource_exact: matches[:suggested_resource_exact],
                                 unmatched: matches[:unmatched])
    end

    # Counts matches for supplied events
    #
    # @param events [Array of SearchEvents] An array of SearchEvents to check for matches.
    # @return [Hash] A Hash with keys for each known algorithm and the count of matched SearchEvents.
    def count_matches(events)
      matches = Hash.new(0)

      events.each do |event|
        event_matches(event, matches)
      end

      matches
    end

    # Checks for matches for a single event
    #
    # @note We currently match StandardIdentifiers and Exact Journals. As we add new algorithms, this method will need
    #  to expand to handle additional match types.
    #
    # @param event [SearchEvent] an individual search event to check for matches
    # @param matches [Hash] a Hash that keeps track of how many of each algorithm we match
    # @return does not return anything (the same matches Hash is passed in each loop but not explicitly sent back)
    def event_matches(event, matches)
      ids = match_standard_identifiers(event, matches)
      journal_exact = process_journals(event, matches)
      suggested_resource_exact = process_suggested_resources(event, matches)

      matches[:unmatched] += 1 if ids.identifiers.blank? && journal_exact.count.zero? && suggested_resource_exact.count.zero?
    end

    # Checks for StandardIdentifer matches
    #
    # @param event [SearchEvent] an individual search event to check for matches
    # @param matches [Hash] a Hash that keeps track of how many of each algorithm we match
    # @return [Array] an array of matched StandardIdentifiers
    def match_standard_identifiers(event, matches)
      known_ids = %i[unmatched pmid isbn issn doi]
      ids = Detector::StandardIdentifiers.new(event.term.phrase)

      known_ids.each do |id|
        matches[id] += 1 if ids.identifiers[id].present?
      end
      ids
    end

    # Checks for Journal matches
    #
    # @note we are only checking for exact matches at this time as the partial match algorithm is more noise than signal
    # @note this detection is not a guarantee of search intent and should not be considered a guarantee that we
    #   understand the search intent. We have not yet done validation on this algoritm to understand what percentage it
    #   is useful. This information should be conveyed in any reports that use this data.
    #
    # @param event [SearchEvent] an individual search event to check for matches
    # @param matches [Hash] a Hash that keeps track of how many of each algorithm we match
    # @return [Array] an array of matched Detector::Journal records
    def process_journals(event, matches)
      journal_exact = Detector::Journal.full_term_match(event.term.phrase)
      matches[:journal_exact] += 1 if journal_exact.count.positive?
      journal_exact
    end

    # Checks for SuggestedResource matches
    #
    # @note This only checks for exact matches of the search term, so any extra or missing words will result in no
    #   match.
    #
    # @param event [SearchEvent] an individual search event to check for matches
    # @param matches [Hash] a Hash that keeps track of how many of each algorithm we match
    # @return [Array] an array of the one Detector::SuggestedResource record whose fingerprint matches that of the
    #   search phrase (if one exists). The uniqueness constraint on the fingerprint should mean there is only ever one
    #   matched record.
    def process_suggested_resources(event, matches)
      suggested_resource_exact = Detector::SuggestedResource.full_term_match(event.term.phrase)
      matches[:suggested_resource_exact] += 1 if suggested_resource_exact.count.positive?
      suggested_resource_exact
    end
  end
end
