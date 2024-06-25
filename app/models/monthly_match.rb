# frozen_string_literal: true

# == Schema Information
#
# Table name: monthly_matches
#
#  id         :integer          not null, primary key
#  month      :date
#  doi        :integer
#  issn       :integer
#  isbn       :integer
#  pmid       :integer
#  unmatched  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# MonthlyMatch aggregates statistics for matches in a given month
#
# @see AggregateMatch
class MonthlyMatch < ApplicationRecord
  # generate data for a provided month
  #
  # @note This is expected to only be run once per month, ideally at the beginning of the following monthto ensure as
  #   accurate as possible statistics. Running further from the month in question will work, but matches will use the
  #   current versions of all algorithms which may not match the algorithm in place during the month the SearchEvent
  #   occurred.
  # @todo Prevent running more than once by checking if we have data and then erroring.
  # @param month [DateTime] A DateTime object within the `month` to be generated.
  # @return [MonthlyMatch] The created MonthlyMatch object.
  def generate_monthly(month)
    matches = count_matches(month)
    MonthlyMatch.create(month:, doi: matches[:doi], issn: matches[:issn], isbn: matches[:isbn],
                        pmid: matches[:pmid], unmatched: matches[:unmatched])
  end

  # Counts matches for the given month
  #
  # @note We currently only have StandardIdentifiers to match. As we add new algorithms, this method will need to
  #   expand to handle additional match types.
  # @param month [DateTime] A DateTime object within the `month` to be generated.
  # @return [Hash] A Hash with keys for each known standard identifier and the count of matched search events.
  def count_matches(month)
    matches = Hash.new(0)
    known_ids = %i[unmatched pmid isbn issn doi]

    SearchEvent.single_month(month).each do |event|
      ids = StandardIdentifiers.new(event.term.phrase)

      matches[:unmatched] += 1 if ids.identifiers.blank?

      known_ids.each do |id|
        matches[id] += 1 if standard_identifier_match?(id, ids)
      end
    end

    matches
  end

  # Returns true if the provided identifier type was matched in this SearchEvent
  #
  # @param identifier [symbol,string] A specific StandardIdentifier type to look for in the SearchEvent, such as `pmid`
  #   or `doi`. We use symbols, but it supports strings as well.
  # @param ids [StandardIdentifiers, Hash] A Hash with matches for know standard identifiers.
  # @return [Hash] A Hash with keys for each known standard identifier and the count of matched search events.
  def standard_identifier_match?(identifier, ids)
    true if ids.identifiers[identifier].present?
  end
end
