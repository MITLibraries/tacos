# frozen_string_literal: true

# == Schema Information
#
# Table name: metrics_algorithms
#
#  id         :integer          not null, primary key
#  month      :date
#  doi        :integer
#  issn       :integer
#  isbn       :integer
#  pmid       :integer
#  unmatched  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
                  count_matches(SearchEvent.all.includes(:term))
                end
      Metrics::Algorithms.create(month:, doi: matches[:doi], issn: matches[:issn], isbn: matches[:isbn],
                                 pmid: matches[:pmid], unmatched: matches[:unmatched])
    end

    # Counts matches supplied events
    #
    # @note We currently only have StandardIdentifiers to match. As we add new algorithms, this method will need to
    #   expand to handle additional match types.
    # @param events [Array of SearchEvents] An array of SearchEvents to check for matches.
    # @return [Hash] A Hash with keys for each known algorithm and the count of matched SearchEvents.
    def count_matches(events)
      matches = Hash.new(0)
      known_ids = %i[unmatched pmid isbn issn doi]

      events.each do |event|
        ids = StandardIdentifiers.new(event.term.phrase)

        matches[:unmatched] += 1 if ids.identifiers.blank?

        known_ids.each do |id|
          matches[id] += 1 if ids.identifiers[id].present?
        end
      end

      matches
    end
  end
end
