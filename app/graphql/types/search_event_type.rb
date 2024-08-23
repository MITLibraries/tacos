# frozen_string_literal: true

module Types
  class SearchEventType < Types::BaseObject
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

    def detectors
      @object.term.phrase
    end
  end
end
