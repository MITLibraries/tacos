# frozen_string_literal: true

# == Schema Information
#
# Table name: suggested_patterns
#
#  id          :integer          not null, primary key
#  confidence  :float            default(0.9)
#  pattern     :string           not null
#  shortcode   :string           not null
#  title       :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#
# Indexes
#
#  index_suggested_patterns_on_category_id  (category_id)
#  index_suggested_patterns_on_pattern      (pattern) UNIQUE
#  index_suggested_patterns_on_shortcode    (shortcode) UNIQUE
#
# Foreign Keys
#
#  category_id  (category_id => categories.id) ON DELETE => nullify
#
class SuggestedPattern < ApplicationRecord
  validates :title, presence: true
  validates :url, presence: true
  validates :pattern, presence: true, uniqueness: true
  validates :shortcode, presence: true, uniqueness: true

  belongs_to :category, optional: true
end
