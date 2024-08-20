class CreateCategorization < ActiveRecord::Migration[7.1]
  def change
    create_table :categorizations do |t|
      t.integer :detection_id
      t.float :transaction_score
      t.float :information_score
      t.float :navigation_score

      t.timestamps
    end
  end
end
