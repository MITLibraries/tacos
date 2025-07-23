# frozen_string_literal: true

module Types
  class CountsType < Types::BaseObject
    description 'Features extracted from the input term that are counts. Useful for machine learning.'

    field :apa_volume_issue, Integer, null: true
    field :brackets, Integer, null: true
    field :characters, Integer, null: true, description: 'Count of characters in the input'
    field :colons, Integer, null: true, description: 'Count of colons in the input'
    field :commas, Integer, null: true, description: 'Count of commas in the input'
    field :counts, CountsType, null: true
    field :lastnames, Integer, null: true
    field :no, Integer, null: true
    field :pages, Integer, null: true
    field :periods, Integer, null: true, description: 'Count of Periods in the input'
    field :pmid, String, null: true
    field :pp, Integer, null: true
    field :quotes, Integer, null: true
    field :semicolons, Integer, null: true, description: 'Count of Semicolons in the input'
    field :vol, Integer, null: true
    field :words, Integer, null: true, description: 'Count of Words in the input'
    field :year_parens, Integer, null: true
  end
end
