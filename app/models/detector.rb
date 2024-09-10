# frozen_string_literal: true

# == Schema Information
#
# Table name: detectors
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Detector < ApplicationRecord
  has_many :detector_categories, dependent: :destroy
  has_many :categories, through: :detector_categories
end
