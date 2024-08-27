# == Schema Information
#
# Table name: detector_base_categories
#
#  id               :integer          not null, primary key
#  detector_base_id :integer
#  category_id      :integer
#  confidence       :float
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Mapping < ApplicationRecord
  belongs_to :detectinator
  belongs_to :category
end
