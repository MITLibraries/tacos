# frozen_string_literal: true

# == Schema Information
#
# Table name: detector_categories
#
#  id          :integer          not null, primary key
#  detector_id :integer          not null
#  category_id :integer          not null
#  confidence  :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class DetectorCategory < ApplicationRecord
  belongs_to :category
  belongs_to :detector
end
