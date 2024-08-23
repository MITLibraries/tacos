# frozen_string_literal: true

module Types
  class DetectorsType < Types::BaseObject
    description 'Provides all available search term detectors'

    field :journals, [Types::JournalsType], description: 'Information about journals detected in the search term'
    field :standard_identifiers, [Types::StandardIdentifiersType], description: 'Currently supported: ISBN, ISSN, PMID, DOI'

    def standard_identifiers
      Detector::StandardIdentifiers.new(@object).identifiers.map do |identifier|
        { kind: identifier.first, value: identifier.last }
      end
    end

    def journals
      Detector::Journal.full_term_match(@object).map do |journal|
        { title: journal.name, additional_info: journal.additional_info }
      end
    end
  end
end
