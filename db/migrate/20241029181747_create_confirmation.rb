class CreateConfirmation < ActiveRecord::Migration[7.1]
  def change
    create_table :confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :term, null: false, foreign_key: true
      t.references :category, null: true, foreign_key: true
      t.boolean :flag

      t.timestamps
    end
    add_index :confirmations, [:term_id, :user_id], unique: true
    add_index :confirmations, [:user_id, :term_id], unique: true
  end
end
