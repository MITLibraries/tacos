# frozen_string_literal: true

module Types
  class CategoriesType < Types::BaseObject
    description 'Information about one category linked to this search term'

    field :confidence, Float, null: false, description: 'The application\'s confidence that the term belongs to this category - measured from 0.0 to 1.0'
    field :name, String, null: false, description: 'The name of this category'

    def name
      @object.category.name
    end
  end
end
