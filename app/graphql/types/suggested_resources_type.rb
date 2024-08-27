# frozen_string_literal: true

module Types
  class SuggestedResourcesType < Types::BaseObject
    description 'A detector for any suggested resources associated with a search term'

    field :title, String, null: false, description: 'The title or name of the suggested resource'
    field :url, String, null: false, description: 'The URL to the suggested resource'
  end
end
