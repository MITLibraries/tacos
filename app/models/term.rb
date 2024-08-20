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
  has_many :detections, dependent: :destroy
end
