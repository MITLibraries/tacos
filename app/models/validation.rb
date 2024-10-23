# frozen_string_literal: true

# Validations are submitted by users as a piece of feedback about the actions taken automatically by TACOS. They are
# associated with their submitting user and a single action (Detection, Categorization) taken by the tool. As a result,
# it is expected that a single Term record will end up having multiple associated Validations.
#
# It is not yet clear how we will support validating actions _not_ taken (i.e. a Detection that should have been created
# but was missed).
#
# == Schema Information
#
# Table name: validations
#
#  id               :integer          not null, primary key
#  validatable_type :string
#  validatable_id   :integer
#  user_id          :integer          not null
#  judgement        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Validation < ApplicationRecord
  belongs_to :validatable, polymorphic: true
end
