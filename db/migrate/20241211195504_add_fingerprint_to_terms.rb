class AddFingerprintToTerms < ActiveRecord::Migration[7.1]
  def up
    add_reference :terms, :fingerprint, foreign_key: true

    # Seed the relationship between Terms and Fingerprints
    # Term.all.each do |t|
    #   t.save
    # end
  end

  def down
    remove_reference :terms, :fingerprint, foreign_key: true
  end
end
