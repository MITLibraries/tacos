# frozen_string_literal: true

module Types
  class JournalsType < Types::BaseObject
    description 'A detector for journal titles in search terms'

    field :additional_info, GraphQL::Types::JSON, description: 'Additional information about the detected journal'
    field :title, String, null: false, description: 'Title of the detected journal'
  end
end
