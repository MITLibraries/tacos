# frozen_string_literal: true

module Types
  class StandardIdentifiersType < Types::BaseObject
    field :kind, String, null: false
    field :value, String, null: false
  end
end
