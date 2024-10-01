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
#  category_id      :integer          not null
#  term_id          :integer          not null
#  confidence       :float
#  detector_version :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Categorization < ApplicationRecord
  belongs_to :term
  belongs_to :category

  # We use the before_create hook to prevent needing to override the initialize method, which Rails frowns upon.
  before_create :set_defaults

  # These scopes allow for easy filtering of Categorization records by a single parameter.
  scope :current, -> { where(detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')) }

  private

  # This looks up the current Detector Version from the environment, storing the value as part of the record which is
  # about to be saved. This prevents the rest of the application from having to worry about this value, while also
  # providing a mechanism to prevent duplicate records from being created.
  def set_defaults
    self.detector_version = ENV.fetch('DETECTOR_VERSION', 'unset')
  end
end
