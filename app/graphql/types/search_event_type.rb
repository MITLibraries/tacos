# frozen_string_literal: true

module Types
  class SearchEventType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :id, ID, null: false
    field :phrase, String
    field :source, String
    field :standard_identifiers, [StandardIdentifiersType]
    field :term_id, Integer
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def phrase
      @object.term.phrase
    end

    def standard_identifiers
      ids = []
      StandardIdentifiers.new(@object.term.phrase).identifiers.each do |identifier|
        ids << { kind: identifier.first, value: identifier.last }
      end
      ids
    end
  end
end
