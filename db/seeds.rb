# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Rails.logger.info('Seeding DB starting')

# Categories
Category.find_or_create_by(
  name: 'Informational',
  description: 'A type of search where the user is looking for broad information, rather than an individual item. Also known as "open-ended" or "topical".'
)
Category.find_or_create_by(
  name: 'Navigational',
  description: 'A type of search where the user has a location in mind, and wants to go there. In library discovery, this should mean a URL that will not be in the searched index.'
)
Category.find_or_create_by(
  name: 'Transactional',
  description: 'A type of search where the user has an item in mind, and wants to get that item. Also known as "known-item".'
)

# Detectors
Detector.find_or_create_by(name: 'DOI')
Detector.find_or_create_by(name: 'ISBN')
Detector.find_or_create_by(name: 'ISSN')
Detector.find_or_create_by(name: 'PMID')
Detector.find_or_create_by(name: 'Journal')
Detector.find_or_create_by(name: 'SuggestedResource')

# DetectorCategories
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'DOI'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.95
)
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'ISBN'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.8
)
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'ISSN'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.6
)
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'PMID'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.95
)
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'Journal'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.2
)

Rails.logger.info('Seeding DB complete')
