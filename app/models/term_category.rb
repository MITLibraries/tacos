# == Schema Information
#
# Table name: term_categories
#
#  id          :integer          not null, primary key
#  term_id     :integer
#  category_id :integer
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class TermCategory < ApplicationRecord
  belongs_to :category
  belongs_to :term
end
