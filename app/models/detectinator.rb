# frozen_string_literal: true

# == Schema Information
#
# Table name: detectinators
#
#  id         :integer          not null, primary key
#  name       :string
#  confidence :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Detectinator < ApplicationRecord
  has_many :mappings
  has_many :categories, :through => :mappings
end
