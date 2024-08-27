# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  note       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Category < ApplicationRecord
  has_many :mappings
  has_many :detectinators, :through => :mappings
  has_many :term_categories, dependent: :destroy
  has_many :terms, :through => :term_categories
end
