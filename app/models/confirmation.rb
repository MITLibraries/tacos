# frozen_string_literal: true

# == Schema Information
#
# Table name: confirmations
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  term_id     :integer          not null
#  category_id :integer
#  flag        :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Confirmation < ApplicationRecord
  belongs_to :user
  belongs_to :term
  belongs_to :category, optional: true
end
