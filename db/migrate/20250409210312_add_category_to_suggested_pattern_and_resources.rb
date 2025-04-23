class AddCategoryToSuggestedPatternAndResources < ActiveRecord::Migration[7.2]
  def change
    add_reference :suggested_resources, :category
    add_foreign_key :suggested_resources, :categories, on_delete: :nullify

    add_reference :suggested_patterns, :category
    add_foreign_key :suggested_patterns, :categories, on_delete: :nullify
  end
end
