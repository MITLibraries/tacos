class CreateDetectorSuggestedResourcePhrases < ActiveRecord::Migration[7.1]
  def change
    create_table :detector_suggested_resource_phrases do |t|
      t.string :phrase
      t.string :fingerprint
      t.belongs_to :detector_suggested_resource, null: false, foreign_key: true

      t.timestamps
    end
  end
end
