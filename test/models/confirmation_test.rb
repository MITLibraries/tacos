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
require 'test_helper'

class ConfirmationTest < ActiveSupport::TestCase
  test 'confirmations must have a user' do
    sample = confirmations('minimal')

    assert_predicate sample.user, :present?
    assert_predicate sample, :valid?

    sample.user = nil

    assert_not_predicate sample, :valid?
  end

  test 'destroying a Confirmation will not affect that User' do
    confirmation_count = Confirmation.count
    user_count = User.count

    record = confirmations('unsure')

    record.destroy

    assert_equal(confirmation_count - 1, Confirmation.count)
    assert_equal(user_count, User.count)
  end

  test 'users cannot confirm the same term twice' do
    old_record = confirmations('minimal')
    new_record = {
      user: old_record.user,
      term: old_record.term
    }

    assert_raises(ActiveRecord::RecordNotUnique) do
      Confirmation.create!(new_record)
    end
  end

  test 'confirmations must have a term' do
    sample = confirmations('minimal')

    assert_predicate sample.term, :present?
    assert_predicate sample, :valid?

    sample.term = nil

    assert_not_predicate sample, :valid?
  end

  test 'destroying a Confirmation will not affect that Term' do
    confirmation_count = Confirmation.count
    term_count = Term.count

    record = confirmations('unsure')

    record.destroy

    assert_equal(confirmation_count - 1, Confirmation.count)
    assert_equal(term_count, Term.count)
  end

  test 'destroying a Confirmation will not affect that Category' do
    confirmation_count = Confirmation.count
    category_count = Category.count

    record = confirmations('unsure')

    record.destroy

    assert_equal(confirmation_count - 1, Confirmation.count)
    assert_equal(category_count, Category.count)
  end
end
