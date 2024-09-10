class CreateDetectors < ActiveRecord::Migration[7.1]
  def change
    create_table :detectors do |t|
      t.string :name

      t.timestamps
    end
    add_index :detectors, :name, unique: true
  end
end
