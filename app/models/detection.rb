# == Schema Information
#
# Table name: detections
#
#  id                :integer          not null, primary key
#  term_id           :integer
#  detection_version :integer
#  doi               :boolean
#  isbn              :boolean
#  issn              :boolean
#  pmid              :boolean
#  journal           :boolean
#  suggestedresource :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Detection < ApplicationRecord
  belongs_to :term
  has_many :categorizations, dependent: :destroy

  validates :detection_version, presence: true

  def initialize(term, *args)
    super(*args)
    self.term = term
    set_detection_version
    record_detections
  end

  private

  def set_detection_version
    self.detection_version = ENV.fetch('DETECTION_VERSION') { '0' }
  end

  def record_detections
    record_patterns
    record_journals
    record_suggested_resources
  end

  def record_patterns
    si = StandardIdentifiers.new(self.term.phrase)
    %i[doi isbn issn pmid].each do |identifier|
      self[identifier] = si.identifiers[identifier].present?
    end
  end

  def record_journals
    self.journal = Detector::Journal.full_term_match(self.term.phrase).present?
  end

  def record_suggested_resources
    self.suggestedresource = Detector::SuggestedResource.full_term_match(self.term.phrase).present?
  end
end
