# frozen_string_literal: true

module Types
  class SearchEventType < Types::BaseObject
    field :id, ID, null: false
    field :term_id, Integer
    field :source, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
