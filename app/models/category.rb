# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Category < ApplicationRecord
  has_many :detector_categories, dependent: :destroy
  has_many :detectors, through: :detector_categories
  has_many :categorizations, dependent: :destroy
  has_many :confirmations, dependent: :destroy
end
