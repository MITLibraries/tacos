# frozen_string_literal: true

# Terms are received by contributing systems. For the moment, they include a single string, which was provided by a user
# as part of a search. This model intentionally includes no other information.
#
# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  phrase     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Term < ApplicationRecord
  has_many :search_events, dependent: :destroy
  has_many :detections, dependent: :destroy

  # The record_detections method is the one-stop method to call every Detector's record method that is defined within
  # the application.
  #
  # @return nil
  def record_detections
    Detector::StandardIdentifiers.record(self)
    Detector::Journal.record(self)
    Detector::SuggestedResource.record(self)

    nil
  end
end
