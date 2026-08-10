# frozen_string_literal: true

# A Categorization is a joining record between a Term and a Category, created when a set of Detections are summarized to
# calculate the final confidence that a Term belongs to a specific Category.
#
# There is a uniqueness constraint on the combination of term_id, category_id, and detector_version.
#
# New records can be created by passing a Term, Category, and a confidence score. The model will look up the current
# detector version, and include that in the record.
#
# == Schema Information
#
# Table name: categorizations
#
#  id               :integer          not null, primary key
#  confidence       :float
#  detector_version :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :integer          not null
#  term_id          :integer          not null
#
# Indexes
#
#  idx_on_term_id_category_id_confidence_detector_vers_2ed1c1cbf9  (term_id,category_id,confidence,detector_version) UNIQUE
#  index_categorizations_on_category_id                            (category_id)
#  index_categorizations_on_term_id                                (term_id)
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#  term_id      (term_id => terms.id)
#
class Categorization < ApplicationRecord
  belongs_to :term
  belongs_to :category

  # These scopes allow for easy filtering of Categorization records by a single parameter.
  scope :current, -> { where(detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')) }
end
