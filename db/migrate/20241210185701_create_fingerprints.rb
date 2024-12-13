class CreateFingerprints < ActiveRecord::Migration[7.1]
  def change
    create_table :fingerprints do |t|
      t.string :value, index: { unique: true, name: 'unique_fingerprint' }
      t.timestamps
    end
  end
end
