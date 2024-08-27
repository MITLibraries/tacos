class AddCategoryToDetectorSuggestedResource < ActiveRecord::Migration[7.1]
  def change
    add_column :detector_suggested_resources, :category_id, :integer
  end
end
