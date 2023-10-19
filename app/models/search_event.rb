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
class SearchEvent < ApplicationRecord
  belongs_to :term

  validates :source, presence: true
end
