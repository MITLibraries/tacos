class CreateCategorization < ActiveRecord::Migration[7.1]
  def change
    create_table :categorizations do |t|
      t.belongs_to :category, null: false, foreign_key: true
      t.belongs_to :term, null: false, foreign_key: true
      t.float :confidence
      t.string :detector_version

      t.timestamps
    end
    add_index :categorizations, [:term_id, :category_id, :detector_version], unique: true
    add_index :categorizations, [:category_id, :term_id, :detector_version], unique: true
  end
end
