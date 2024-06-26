# frozen_string_literal: true

# Counts matches supplied events
module MatchCounter
  # Counts matches supplied events
  #
  # @note We currently only have StandardIdentifiers to match. As we add new algorithms, this method will need to
  #   expand to handle additional match types.
  # @param events [Array of SearchEvents] An array of SearchEvents to check for matches.
  # @return [Hash] A Hash with keys for each known standard identifier and the count of matched search events.
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
