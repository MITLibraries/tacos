# frozen_string_literal: true

module Types
  class FeaturesType < Types::BaseObject
    description 'Features extracted from the input term. Useful for machine learning.'

    field :counts, CountsType, null: true
    field :doi, String, null: true
    field :isbn, String, null: true
    field :issn, String, null: true
    field :journal, String, null: true
    field :ml_citation, Boolean, null: true
    field :pmid, String, null: true
  end
end
