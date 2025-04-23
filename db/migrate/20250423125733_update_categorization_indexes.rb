class UpdateCategorizationIndexes < ActiveRecord::Migration[7.2]
  def change
    remove_index :categorizations, [:term_id, :category_id, :detector_version]
    remove_index :categorizations, [:category_id, :term_id, :detector_version]

    add_index :categorizations, [:term_id, :category_id, :confidence, :detector_version], unique: true
  end
end
