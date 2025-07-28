# frozen_string_literal: true

module Types
  class CountsType < Types::BaseObject
    description 'Features extracted from the input term that are counts. Useful for machine learning.'

    field :apa_volume_issue, Integer, null: true, description: 'Count of apa volume number pattern in the input'
    field :brackets, Integer, null: true, description: 'Count of brackets in the input'
    field :characters, Integer, null: true, description: 'Count of characters in the input'
    field :colons, Integer, null: true, description: 'Count of colons in the input'
    field :commas, Integer, null: true, description: 'Count of commas in the input'
    field :lastnames, Integer, null: true, description: 'Count of lastnames in the input. Not recommended for use in production.'
    field :no, Integer, null: true, description: 'Count of `no` in the input'
    field :pages, Integer, null: true, description: 'Count of `pages` in the input'
    field :periods, Integer, null: true, description: 'Count of Periods in the input'
    field :pp, Integer, null: true, description: 'Count of `pp` in the input'
    field :quotes, Integer, null: true, description: 'Count of &quot in the input'
    field :semicolons, Integer, null: true, description: 'Count of Semicolons in the input'
    field :vol, Integer, null: true, description: 'Count of `vol` in the input'
    field :words, Integer, null: true, description: 'Count of Words in the input'
    field :year_parens, Integer, null: true, description: 'Count of (year) in the input'
  end
end
