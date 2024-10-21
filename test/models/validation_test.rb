# frozen_string_literal: true

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
require 'test_helper'

class ValidationTest < ActiveSupport::TestCase
  test 'validations can attach to detections' do
    v = Validation.new(
      validatable: Detection.first,
      user_id: User.first.id,
      judgement: 1
    )

    assert_predicate(v, :valid?)
  end

  test 'validations can attach to categorizations' do
    v = Validation.new(
      validatable: Categorization.first,
      user_id: User.first.id,
      judgement: 1
    )

    assert_predicate(v, :valid?)
  end

  test 'users can only validate something once' do
    validation_count = Validation.count
    sample_user = User.first

    sample = {
      validatable: Detection.first,
      user_id: sample_user.id,
      judgement: 1
    }
    Validation.create!(sample)

    assert_equal validation_count + 1, Validation.count

    assert_raises(ActiveRecord::RecordNotUnique) do
      Validation.create!(sample)
    end
  end

  test 'multiple users can validate the same record' do
    validation_count = Validation.count
    target = Detection.first

    Validation.create!(
      validatable: target,
      user_id: users('basic').id,
      judgement: 1
    )

    Validation.create!(
      validatable: target,
      user_id: users('admin').id,
      judgement: -1
    )

    assert_equal validation_count + 2, Validation.count
  end
end
