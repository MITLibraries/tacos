class CreateDetectorBase < ActiveRecord::Migration[7.1]
  def change
    create_table :detector_bases do |t|
      t.string :name
      t.float :confidence

      t.timestamps
    end

    Detector::Base.create(name: 'DOI', confidence: 0.95)
    Detector::Base.create(name: 'ISBN', confidence: 0.8)
    Detector::Base.create(name: 'ISSN', confidence: 0.6)
    Detector::Base.create(name: 'PMID', confidence: 0.95)
    Detector::Base.create(name: 'Journal', confidence: 0.2)
    Detector::Base.create(name: 'Suggested Resource', confidence: 0.5)
  end
end
