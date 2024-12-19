class CreateJournals < ActiveRecord::Migration[7.1]
  def change
    create_table :journals do |t|
      t.string :name
      t.json :additional_info

      t.timestamps
    end
    add_index :journals, :name
  end
end
