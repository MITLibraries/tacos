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
end
