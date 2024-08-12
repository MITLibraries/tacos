# frozen_string_literal: true

module Types
  class TermType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :id, ID, null: false
    field :occurence_count, Integer
    field :phrase, String, null: false
    field :search_events, [SearchEventType], null: false
    field :standard_identifiers, [StandardIdentifiersType]
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def occurence_count
      @object.search_events.count
    end

    def standard_identifiers
      ids = []
      StandardIdentifiers.new(@object.phrase).identifiers.each do |identifier|
        ids << { kind: identifier.first, value: identifier.last }
      end
      ids
    end
  end
end
