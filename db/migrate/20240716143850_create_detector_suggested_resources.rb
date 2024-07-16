class CreateDetectorSuggestedResources < ActiveRecord::Migration[7.1]
  def change
    create_table :detector_suggested_resources do |t|
      t.string :title
      t.string :url
      t.string :phrase
      t.string :fingerprint

      t.timestamps
    end
    add_index :detector_suggested_resources, :phrase, unique: true
    add_index :detector_suggested_resources, :fingerprint, unique: true
  end
end
