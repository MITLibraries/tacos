# frozen_string_literal: true

# SearchLogger handles logging of search events including coordination of any preprocessing or normalization
# of data.
class SearchLogger
  # Receives a phrase and source and creates a search event. Will find or create a term as needed.
  # @return [SearchEvent] the newly created SearchEvent
  def self.logevent(phrase, source)
    term = Term.create_or_find_by!(phrase: extract_phrase(phrase, source))
    term.calculate_categorizations
    term.search_events.create!(source:)
  end

  # Coordinates `phrase` extraction from incoming data from each `source`. If no `source` is matched,
  # passes through incoming `phrase`.
  # Note: as it may become useful to test in a production environment, we match on patterns of sources
  # rather than exact string matches. Example: `primo`, `primo-testing`, `primo-playground` are all handled
  # with the same case.
  def self.extract_phrase(phrase, source)
    case source
    when /primo/
      Rails.logger.debug('Primo case detected')
      PreprocessorPrimo.to_tacos(phrase)
    else
      Rails.logger.debug('default case detected')
      phrase
    end
  end
end
