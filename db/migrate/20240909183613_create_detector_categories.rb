class CreateDetectorCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :detector_categories do |t|
      t.belongs_to :detector, null: false, foreign_key: true
      t.belongs_to :category, null: false, foreign_key: true
      t.float :confidence

      t.timestamps
    end
    add_index :detector_categories, [:detector_id, :category_id]
    add_index :detector_categories, [:category_id, :detector_id]
  end
end
