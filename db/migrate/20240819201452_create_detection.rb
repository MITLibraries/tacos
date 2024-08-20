class CreateDetection < ActiveRecord::Migration[7.1]
  def change
    create_table :detections do |t|
      t.integer :term_id
      t.integer :detection_version
      t.boolean :doi
      t.boolean :isbn
      t.boolean :issn
      t.boolean :pmid
      t.boolean :journal
      t.boolean :suggestedresource

      t.timestamps
    end
  end
end
