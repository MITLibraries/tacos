# frozen_string_literal: true

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
  has_many :term_detectinators, dependent: :destroy
  has_many :detectinators, :through => :term_detectinators
  has_many :term_categories, dependent: :destroy
  has_many :categories, :through => :term_categories

  def evaluate_detectinators
    evaluate_identifiers
    evaluate_journals
    evaluate_suggested_resource
  end

  def evaluate_identifiers
    si = StandardIdentifiers.new(phrase)

    si.identifiers.each do |k, v|
      link = TermDetectinator.new(self)
      link.detectinator = Detectinator.where("name = '#{k.to_s.upcase}'").first
      link.result = v.present?

      link.save
    end
  end

  def evaluate_journals
    result = Detector::Journal.full_term_match(phrase)
    if result.any?
      link = TermDetectinator.new(self)
      link.detectinator = Detectinator.where("name = 'Journal'").first
      link.result = true
      link.save
    end
  end

  def evaluate_suggested_resource
    result = Detector::SuggestedResource.full_term_match(phrase)
    if result.any?
      link = TermDetectinator.new(self)
      link.detectinator = Detectinator.where("name = 'Suggested Resource'").first
      link.result = true
      link.save
    end
  end

  # This is intended to be a method which calculates the confidence scores for each category, by multiplying the
  # confidence values. Right now the method is only taking baby steps toward that work, however. The method currently
  # generates log messages such as:
  #
  # This method will calculate the confidence scores for this term.
  # Transactional-PMID: 0.95 * 0.95 = 0.9025
  # Transactional-DOI: 0.95 * 0.95 = 0.9025
  #
  # ... if a given term trips two Transaction-facing detectors that have confidence scores of 0.95.
  def categorize
    Rails.logger.info("This method will calculate the confidence scores for this term.")
    # self.detectinators.uniq.each { |d| d.mappings.uniq.each { |m| puts d.confidence * m.confidence } }
    self.detectinators.uniq.each do |d|
      d.mappings.uniq.each do |m|
        Rails.logger.info("#{m.category.name.to_s}-#{d.name.to_s}: #{d.confidence.to_s} * #{m.confidence.to_s} = #{(d.confidence * m.confidence).to_s}")
      end
    end
  end
end
