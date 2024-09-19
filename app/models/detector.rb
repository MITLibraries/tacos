# frozen_string_literal: true

# Detectors are a generic representation of specific checks performed by the
# application. Examples include the Detector::Journal or
# Detector::StandardIdentifier checks.
#
# @note A Detector record must be created for each check in the application, and
#       joined to the relevant Category record as part of the application's
#       knowledge graph.
#
# @note Detectors are joined to Term records via the Detections class.
#
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
  has_many :detections, dependent: :destroy
end
