# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_categories_on_name  (name) UNIQUE
#
class Category < ApplicationRecord
  has_many :detector_categories, dependent: :destroy
  has_many :detectors, through: :detector_categories
  has_many :categorizations, dependent: :destroy
  has_many :confirmations, dependent: :destroy
end
