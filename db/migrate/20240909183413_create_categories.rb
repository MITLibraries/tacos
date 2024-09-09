class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :detectors do |t|
      t.string :name
      t.float :confidence

      t.timestamps
    end
    add_index :detectors, :name, unique: true

    create_table :categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :categories, :name, unique: true

    create_table :detector_categories do |t|
      t.belongs_to :detector, null: false, foreign_key: true
      t.belongs_to :category, null: false, foreign_key: true
      t.float :confidence

      t.timestamps
    end

    Detector.create(name: 'DOI', confidence: 0.95)
    Detector.create(name: 'ISBN', confidence: 0.8)
    Detector.create(name: 'ISSN', confidence: 0.6)
    Detector.create(name: 'PMID', confidence: 0.95)
    Detector.create(name: 'Journal', confidence: 0.2)
    Detector.create(name: 'SuggestedResource', confidence: 0.95)

    Category.create(name: 'Informational', description: 'A type of search where the user is looking for broad information, rather than an individual item. Also known as "open-ended" or "topical".')
    Category.create(name: 'Navigational', description: 'A type of search where the user has a location in mind, and wants to go there. In library discovery, this should mean a URL that will not be in the searched index.')
    Category.create(name: 'Transactional', description: 'A type of search where the user has an item in mind, and wants to get that item. Also known as "known-item".')

    DetectorCategory.create(detector: Detector.find_by(name: 'DOI'), category: Category.find_by(name: 'Transactional'), confidence: 0.95)
    DetectorCategory.create(detector: Detector.find_by(name: 'ISBN'), category: Category.find_by(name: 'Transactional'), confidence: 0.95)
    DetectorCategory.create(detector: Detector.find_by(name: 'ISSN'), category: Category.find_by(name: 'Transactional'), confidence: 0.95)
    DetectorCategory.create(detector: Detector.find_by(name: 'PMID'), category: Category.find_by(name: 'Transactional'), confidence: 0.95)
    DetectorCategory.create(detector: Detector.find_by(name: 'Journal'), category: Category.find_by(name: 'Transactional'), confidence: 0.5)
  end
end
