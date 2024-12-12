class AddFingerprintToTerms < ActiveRecord::Migration[7.1]
  def up
    add_reference :terms, :fingerprint, foreign_key: true
  end

  def down
    remove_reference :terms, :fingerprint, foreign_key: true
  end
end
