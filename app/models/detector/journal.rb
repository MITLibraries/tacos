# frozen_string_literal: true

# == Schema Information
#
# Table name: detector_journals
#
#  id              :integer          not null, primary key
#  name            :string
#  additional_info :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module Detector
  # Detector::Journal stores information about academic journals loaded from external sources to allow us to check our
  # incoming Terms against these information
  class Journal < ApplicationRecord
    before_save :downcase_fields!

    # Identify journals in which the incoming phrase matches a Journal.name exactly
    #
    # @note We always store the Journal.name downcased, so we should also always downcase the phrase
    #   when matching
    #
    # @note In reality, multiple Journals can exist with the same name. Therefore, we don't enforce
    #   unique names and don't expect a single Journal to be returned.
    #
    # @param phrase [String]. A string representation of a search term (not an actual Term object!)
    #
    # @return [Set of Detector::Journal] A set of ActiveRecord Detector::Journal relations.
    def self.full_term_match(phrase)
      Journal.where(name: phrase.downcase)
    end

    # Identify journals in which the incoming phrase contains one or more Journal names
    #
    # @note This likely won't scale well and may not be suitable for live detection as it loads all Journal records.
    #
    # @param phrase [String]. A string representation of a search term (not an actual Term object!)
    #
    # @return [Set of Detector::Journal] A set of ActiveRecord Detector::Journal relations.
    def self.partial_term_match(phrase)
      Journal.all.map { |journal| journal if phrase.downcase.include?(journal.name) }.compact
    end

    private

    # Downcasing all names before saving allows for more efficient matching by ensuring our index is lowercase.
    # If we find we need the non-lowercase Journal name in the future, we could store that as `additional_info` json
    def downcase_fields!
      name.downcase!
    end
  end
end
