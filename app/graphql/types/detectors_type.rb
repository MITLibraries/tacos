# frozen_string_literal: true

module Types
  class DetectorsType < Types::BaseObject
    description 'Provides all available search term detectors'

    field :journals, [Types::JournalsType], description: 'Information about journals detected in the search term'
    field :lcsh, [String], description: 'Library of Congress Subject Heading information'
    field :standard_identifiers, [Types::StandardIdentifiersType], description: 'Currently supported: ISBN, ISSN, PMID, DOI'
    field :suggested_resources, [Types::SuggestedResourcesType], description: 'Suggested resources detected in the search term'

    def journals
      Detector::Journal.full_term_match(@object).map do |journal|
        { title: journal.name, additional_info: journal.additional_info }
      end
    end

    def lcsh
      Detector::Lcsh.new(@object).detections.map(&:last)
    end

    def standard_identifiers
      Detector::StandardIdentifiers.new(@object).detections.map do |identifier|
        { kind: identifier.first, value: identifier.last }
      end
    end

    # Prefer Term based SuggestedResources over Pattern Based Suggested Resources
    def suggested_resources
      traditional_suggested_resources.presence || pattern_based_suggested_resources
    end

    def traditional_suggested_resources
      Detector::SuggestedResource.full_term_match(@object) do |suggested_resource|
        { title: suggested_resource.title, url: suggested_resource.url }
      end
    end

    def pattern_based_suggested_resources
      Detector::SuggestedResourcePattern.new(@object).detections do |suggested_resource|
        { title: suggested_resource.title, url: suggested_resource.url }
      end
    end
  end
end
