# frozen_string_literal: true

# Terms are received by contributing systems. For the moment, they include a single string, which was provided by a user
# as part of a search. This model intentionally includes no other information.
#
# == Schema Information
#
# Table name: terms
#
#  id             :integer          not null, primary key
#  phrase         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  flag           :boolean
#  fingerprint_id :integer
#
class Term < ApplicationRecord
  has_many :search_events, dependent: :destroy
  has_many :detections, dependent: :destroy
  has_many :categorizations, dependent: :destroy
  has_many :confirmations, dependent: :destroy
  belongs_to :fingerprint, optional: true

  before_save :register_fingerprint
  after_destroy :check_fingerprint_count

  scope :user_confirmed, -> { where.associated(:confirmations).distinct }
  scope :user_unconfirmed, -> { where.missing(:confirmations).distinct }

  # The fingerprint method returns the constructed fingerprint field from the related Fingerprint record. In the
  # rare condition when no Fingerprint record exists, this method returns Nil.
  delegate :fingerprint_value, to: :fingerprint, allow_nil: true

  # The cluster method returns an array of all Term records which share a fingerprint with the current term. The term
  # itself is not returned, so if a term has no related records, this method returns an empty array.
  #
  # @note In the rare case when a Term has no fingerprint, this method returns Nil.
  #
  # @return array
  def cluster
    fingerprint&.terms&.filter { |rel| rel != self }
  end

  # The record_detections method is the one-stop method to call every Detector's record method that is defined within
  # the application.
  #
  # @return nil
  def record_detections
    Detector::Citation.record(self)
    Detector::StandardIdentifiers.record(self)
    Detector::Journal.record(self)
    Detector::Lcsh.record(self)
    Detector::SuggestedResource.record(self)

    nil
  end

  # Receives an array of individual confidence values, and returns the calculated categorization score.
  #
  # @note For now, we are just calculating the average of all confidences, but this was chosen arbitrarily. This will
  #       need to be studied more rigorously when we have more data.
  #
  # @return float
  def calculate_confidence(values)
    (values.sum / values.size).round(2)
  end

  # The combined_scores method queries all current detections' confidence scores, and remaps them to a structure that
  # is easy to summarize to categorization scores.
  #
  # @return array of hashes, e.g. [ { 3 => [ 0.95, 0.95 ] }, { 1 => [ 0.1 ] } ]
  def calculate_categorizations
    record_detections
    scores = retrieve_detection_scores
    # scores looks like [{3=>[0.91, 0.95]}, {1=>[0.1]}]
    scores.map do |obj|
      obj.map do |cat, vals|
        Categorization.find_or_create_by(
          term: self,
          category: Category.where(id: cat).first,
          confidence: calculate_confidence(vals),
          detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
        )
      end
    end
  end

  private

  # register_fingerprint method gets called before a Term record is saved, ensuring that Terms should always have a
  # related Fingerprint method.
  def register_fingerprint
    new_record = {
      value: Fingerprint.calculate(phrase)
    }
    self.fingerprint = Fingerprint.find_or_create_by(new_record)
  end

  # This is called during the after_destroy hook. If removing that term means that its fingerprint is now abandoned,
  # then we destroy the fingerprint too. In the rare case when a Term does not have a fingerprint, this method does not
  # cause problems because of the safe operators in the conditional.
  def check_fingerprint_count
    fingerprint.destroy if fingerprint&.terms&.count&.zero?
  end

  # This method looks up all current detections for the given term, and assembles their confidence scores in a format
  # usable by the calculate_categorizations method. It exists to transform data like:
  # [{3=>0.91}, {1=>0.1}] and [{3=>0.95}]
  # into [{3=>[0.91, 0.95]}, {1=>[0.1]}]
  #
  # @return an array of hashes, e.g. [{3=>[0.91, 0.95]}, {1=>[0.1]}]
  def retrieve_detection_scores
    # The detections.scores method returns data like [{3=>0.91}, {1=>0.1}] and [{3=>0.95}]
    raw = detections.current.flat_map(&:scores)
    # raw looks like [{3=>0.91}, {1=>0.1}, {3=>0.95}]
    raw.group_by { |h| h.keys.first }.map { |k, v| { k => v.map { |h| h.values.first } } }
  end
end
