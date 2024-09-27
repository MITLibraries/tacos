# frozen_string_literal: true

module Types
  class SearchEventType < Types::BaseObject
    field :categories, [Types::CategoriesType], description: 'The list of categories linked to term provided in this search'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :detectors, Types::DetectorsType
    field :id, ID, null: false
    field :phrase, String
    field :source, String
    field :term_id, Integer
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def phrase
      @object.term.phrase
    end

    def categories
      @object.term.categorizations
    end

    def detectors
      @object.term.phrase
    end
  end
end
