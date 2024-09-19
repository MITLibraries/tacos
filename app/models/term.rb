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

  # The record_detections method is the one-stop method to call every Detector defined within the application.
  #
  # @return None
  def record_detections
    record_patterns
    record_journals
    record_suggested_resources
  end

  # The record_patterns method will consult the set of regex-based detectors that are defined in
  # Detector::StandardIdentifiers. Any matches will be registered as Detection records.
  #
  # @note There are multiple checks within the Detector::StandardIdentifier class. Each check is capable of generating
  #       a separate Detection record (although a single check finding multiple matches would still only result in one
  #       Detection for that check).
  def record_patterns
    si = Detector::StandardIdentifiers.new(phrase)

    si.identifiers.each_key do |k|
      Detection.find_or_create_by(
        term: self,
        detector: Detector.where(name: k.to_s.upcase).first
      )
    end
  end

  # Look up any matching Detector::Journal records, using the full_term_match method. If a match is found, a Detection
  # record is created to indicate this success.
  #
  # @note This does not care whether multiple matching journals are detected. If _any_ match is found, a Detection
  #       record is created. The uniqueness constraint on Detection records would make multiple detections irrelevant.
  def record_journals
    result = Detector::Journal.full_term_match(phrase)
    return unless result.any?

    Detection.find_or_create_by(
      term: self,
      detector: Detector.where("name = 'Journal'").first
    )
  end

  # Look up any matching Detector::SuggestedResource records, using the full_term_match method. If a match is found, a
  # Detection record is created to indicate this success.
  #
  # @note Multiple matches with Detector::SuggestedResource are not possible due to internal constraints in that
  #       detector, which requires a unique fingerprint for every record.
  #
  # @note Multiple detections are irrelevant for this method. If _any_ match is found, a Detection record is created.
  #       The uniqueness contraint on Detection records would make multiple detections irrelevant.
  def record_suggested_resources
    result = Detector::SuggestedResource.full_term_match(phrase)
    return unless result.any?

    Detection.find_or_create_by(
      term: self,
      detector: Detector.where("name = 'SuggestedResource'").first
    )
  end
end
