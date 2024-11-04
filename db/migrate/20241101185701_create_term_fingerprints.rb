class CreateTermFingerprints < ActiveRecord::Migration[7.1]
  def change
    create_table :term_fingerprints do |t|
      t.string :fingerprint, index: { unique: true, name: 'unique_fingerprint' }
      t.timestamps
    end
  end
end
