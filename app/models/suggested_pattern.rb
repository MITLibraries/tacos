# frozen_string_literal: true

# == Schema Information
#
# Table name: suggested_patterns
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  url         :string           not null
#  pattern     :string           not null
#  shortcode   :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#  confidence  :float            default(0.9)
#
class SuggestedPattern < ApplicationRecord
  validates :title, presence: true
  validates :url, presence: true
  validates :pattern, presence: true, uniqueness: true
  validates :shortcode, presence: true, uniqueness: true

  belongs_to :category, optional: true
end
