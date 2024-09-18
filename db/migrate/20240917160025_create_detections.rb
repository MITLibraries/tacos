class CreateDetections < ActiveRecord::Migration[7.1]
  def change
    create_table :detections do |t|
      t.belongs_to :term, null: false, foreign_key: true
      t.belongs_to :detector, null: false, foreign_key: true
      t.string :detector_version

      t.timestamps
    end
    add_index :detections, [:term_id, :detector_id, :detector_version], unique: true
    add_index :detections, [:detector_id, :term_id, :detector_version], unique: true
  end
end
