# frozen_string_literal: true

# A Detection is a joining record between a Term and a Detector, created when a Detector activates based on some aspect
# of the Term. This is the signal that TACOS found something about this Term.
#
# There is a uniqueness constraint on the combination of term_id, detector_id, and detector_version.
#
# New records can be created by passing a Term and a Detector object. The model will look up the current detector
# version, and include that in the record.
#
# == Schema Information
#
# Table name: detections
#
#  id               :integer          not null, primary key
#  term_id          :integer          not null
#  detector_id      :integer          not null
#  detector_version :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Detection < ApplicationRecord
  belongs_to :term
  belongs_to :detector

  # We use the before_create hook to prevent needing to override the initialize method, which Rails frowns upon.
  before_create :set_defaults

  # These scopes allow for easy filtering of Detection records by a single parameter.
  scope :current, -> { where(detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')) }
  scope :for_detector, ->(detector) { where(detector_id: detector.id) }
  scope :for_term, ->(term) { where(term_id: term.id) }

  private

  # This looks up the current Detector Version from the environment, storing the value as part of the record which is
  # about to be saved. This prevents the rest of the application from having to worry about this value, while also
  # providing a mechanism to prevent duplicate records from being created.
  def set_defaults
    self.detector_version = ENV.fetch('DETECTOR_VERSION', 'unset')
  end
end
