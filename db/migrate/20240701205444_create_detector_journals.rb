class CreateDetectorJournals < ActiveRecord::Migration[7.1]
  def change
    create_table :detector_journals do |t|
      t.string :name
      t.json :additional_info

      t.timestamps
    end
    add_index :detector_journals, :name
  end
end
