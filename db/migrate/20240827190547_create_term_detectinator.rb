class CreateTermDetectinator < ActiveRecord::Migration[7.1]
  def change
    create_table :term_detectinators do |t|
      t.integer :term_id
      t.integer :detectinator_id
      t.boolean :result

      t.timestamps
    end

    create_table :term_categories do |t|
      t.integer :term_id
      t.integer :category_id
      t.integer :user_id

      t.timestamps
    end
  end
end
