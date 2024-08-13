# frozen_string_literal: true

# == Schema Information
#
# Table name: search_events
#
#  id         :integer          not null, primary key
#  term_id    :integer
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# SearchEvent represents an instance of a logged search Term
class SearchEvent < ApplicationRecord
  belongs_to :term

  validates :source, presence: true

  # :single_month filters to requested month
  #
  #   @param month [DateTime] A DateTime object within the `month` to be filtered.
  #   @return [Array<SearchEvent>] All SearchEvents for the supplied `month`.
  scope :single_month, ->(month) { where(created_at: month.all_month) }
end
