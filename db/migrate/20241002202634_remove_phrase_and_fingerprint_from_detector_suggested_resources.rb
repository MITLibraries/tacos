class RemovePhraseAndFingerprintFromDetectorSuggestedResources < ActiveRecord::Migration[7.1]
  def change
    remove_column :detector_suggested_resources, :phrase
    remove_column :detector_suggested_resources, :fingerprint
  end
end
