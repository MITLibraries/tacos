# frozen_string_literal: true

# == Schema Information
#
# Table name: aggregate_matches
#
#  id         :integer          not null, primary key
#  doi        :integer
#  issn       :integer
#  isbn       :integer
#  pmid       :integer
#  unmatched  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# AggregateMatch aggregates statistics for matches for all SearchEvents
#
# @see MonthlyMatch
class AggregateMatch < ApplicationRecord
  include MatchCounter

  # generate data for all SearchEvents
  #
  # @note This is expected to only be run once per month, ideally at the beginning of the following monthto ensure as
  #   accurate as possible statistics. Running further from the month in question will work, but matches will use the
  #   current versions of all algorithms which may not allow for tracking algorithm performance
  #   over time as accurately as intended.
  # @todo Prevent running more than once by checking if we have data and then erroring?
  # @return [AggregateMatch] The created AggregateMatch object.
  def generate
    matches = AggregateMatch.count_matches(SearchEvent.all)
    AggregateMatch.create(doi: matches[:doi], issn: matches[:issn], isbn: matches[:isbn],
                          pmid: matches[:pmid], unmatched: matches[:unmatched])
  end
end
