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
  include MatchCounter

  # generate data for a provided month
  #
  # @note This is expected to only be run once per month, ideally at the beginning of the following monthto ensure as
  #   accurate as possible statistics. Running further from the month in question will work, but matches will use the
  #   current versions of all algorithms which may not match the algorithm in place during the month the SearchEvent
  #   occurred.
  # @todo Prevent running more than once by checking if we have data and then erroring.
  # @param month [DateTime] A DateTime object within the `month` to be generated.
  # @return [MonthlyMatch] The created MonthlyMatch object.
  def generate(month)
    matches = count_matches(SearchEvent.single_month(month))
    MonthlyMatch.create(month:, doi: matches[:doi], issn: matches[:issn], isbn: matches[:isbn],
                        pmid: matches[:pmid], unmatched: matches[:unmatched])
  end
end
