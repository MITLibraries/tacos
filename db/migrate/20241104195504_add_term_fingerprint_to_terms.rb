class AddTermFingerprintToTerms < ActiveRecord::Migration[7.1]
  def up
    add_reference :terms, :term_fingerprint, foreign_key: true

    # Seed the relationship between Terms and TermFingerprints
    Term.all.each do |t|
      t.save
    end
  end

  def down
    remove_reference :terms, :term_fingerprint, foreign_key: true
  end
end
