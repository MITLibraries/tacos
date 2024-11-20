# frozen_string_literal: true

# SearchLogger handles logging of search events including coordination of any preprocessing or normalization
# of data.
class SearchLogger
  # Receives a phrase and source and creates a search event. Will find or create a term as needed.
  # @return [SearchEvent] the newly created SearchEvent
  def self.logevent(phrase, source)
    term = Term.create_or_find_by!(phrase:)
    term.calculate_categorizations
    term.search_events.create!(source:)
  end
end
