class AddSuggestedPatterns < ActiveRecord::Migration[7.2]
  def change
    create_table :suggested_patterns do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.string :pattern, null: false
      t.string :shortcode, null: false

      t.timestamps
    end

    add_index :suggested_patterns, :pattern, unique: true
    add_index :suggested_patterns, :shortcode, unique: true
  end
end
