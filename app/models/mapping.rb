# == Schema Information
#
# Table name: mappings
#
#  id              :integer          not null, primary key
#  category_id     :integer
#  detectinator_id :integer
#  confidence      :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Mapping < ApplicationRecord
  belongs_to :detectinator
  belongs_to :category
end
