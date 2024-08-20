# frozen_string_literal: true

# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  phrase     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  category   :integer
#
class Term < ApplicationRecord
  has_many :search_events, dependent: :destroy
  has_many :detections, dependent: :destroy

  enum category: {
    informational: 0,
    navigational: 1,
    transactional: 2,
    unknown: 3
  }
end
