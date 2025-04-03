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
Category.find_or_create_by(
  name: 'Undefined',
  description: 'A search which has not been placed in one of the other categories.'
)
Category.find_or_create_by(
  name: 'Flagged',
  description: 'A search which has sensitive information that should be excluded from further processing.'
)

# Detectors
Detector.find_or_create_by(name: 'DOI')
Detector.find_or_create_by(name: 'ISBN')
Detector.find_or_create_by(name: 'ISSN')
Detector.find_or_create_by(name: 'LCSH')
Detector.find_or_create_by(name: 'PMID')
Detector.find_or_create_by(name: 'Journal')
Detector.find_or_create_by(name: 'SuggestedResource')
Detector.find_or_create_by(name: 'Citation')
Detector.find_or_create_by(name: 'Barcode')
Detector.find_or_create_by(name: 'SuggestedResourcePattern')

# DetectorCategories
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'Barcode'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.95
)
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'Citation'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.3
)
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
  detector: Detector.find_by(name: 'LCSH'),
  category: Category.find_by(name: 'Informational'),
  confidence: 0.7
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
DetectorCategory.find_or_create_by(
  detector: Detector.find_by(name: 'SuggestedResourcePattern'),
  category: Category.find_by(name: 'Transactional'),
  confidence: 0.9
)

# Patterns for Suggested Resources
SuggestedPattern.find_or_create_by(
  title: 'Looking for Standards?',
  url: 'https://libguides.mit.edu/standards',
  pattern: '(IEC|iec)(\\s)(\\d{5})',
  shortcode: 'iec'
)
SuggestedPattern.find_or_create_by(
  title: 'Looking for Standards?',
  url: 'https://libguides.mit.edu/standards',
  pattern: '(ASCE|asce)(\\s)(\\d)',
  shortcode: 'asce'
)
SuggestedPattern.find_or_create_by(
  title: 'Looking for Standards?',
  url: 'https://libguides.mit.edu/standards',
  pattern: '(IEEE|ieee)\\s+(?:Std\\s+)?([PC]?[0-9]{3,4})',
  shortcode: 'ieee'
)
SuggestedPattern.find_or_create_by(
  title: 'Looking for Standards?',
  url: 'https://libguides.mit.edu/standards',
  pattern: '(ISO|iso)\\s(\\d{1,5})',
  shortcode: 'iso'
)
SuggestedPattern.find_or_create_by(
  title: 'Looking for Standards?',
  url: 'https://libguides.mit.edu/standards',
  pattern: '(ASTM|astm)\\s',
  shortcode: 'astm'
)

Rails.logger.info('Seeding DB complete')
