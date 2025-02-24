# frozen_string_literal: true

# A Confirmation is a "ground truth" record, provided by a person who has
# reviewed a Term record and recommended how TACOS should classify the term
# during the categorization workflow. Most of the time, we anticipate that the
# user will place the term into one of the primary categories. If no category
# seems appropriate, there is an "undefined" option available (which is not
# used by TACOS' automated categorization workflow). There is also a "flagged"
# category, in case the user feels that the term should be reviewed and removed
# from the dataset entirely.
#
# == Schema Information
#
# Table name: confirmations
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  term_id     :integer          not null
#  category_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Confirmation < ApplicationRecord
  belongs_to :user
  belongs_to :term
  belongs_to :category
end
