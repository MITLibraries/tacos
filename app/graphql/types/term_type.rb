# frozen_string_literal: true

module Types
  class TermType < Types::BaseObject
    field :categories, [Types::CategoriesType], description: 'The list of categories linked to this term'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :detectors, Types::DetectorsType
    field :id, ID, null: false
    field :occurence_count, Integer
    field :phrase, String, null: false
    field :search_events, [SearchEventType], null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def occurence_count
      @object.search_events.count
    end

    def categories
      @object.categorizations
    end

    def detectors
      @object.phrase
    end
  end
end
