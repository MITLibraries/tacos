# frozen_string_literal: true

# == Schema Information
#
# Table name: detector_categories
#
#  id          :integer          not null, primary key
#  confidence  :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer          not null
#  detector_id :integer          not null
#
# Indexes
#
#  index_detector_categories_on_category_id                  (category_id)
#  index_detector_categories_on_category_id_and_detector_id  (category_id,detector_id)
#  index_detector_categories_on_detector_id                  (detector_id)
#  index_detector_categories_on_detector_id_and_category_id  (detector_id,category_id)
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#  detector_id  (detector_id => detectors.id)
#
class DetectorCategory < ApplicationRecord
  belongs_to :category
  belongs_to :detector
end
