# frozen_string_literal: true

# == Schema Information
#
# Table name: confirmations
#
#  id          :integer          not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer          not null
#  term_id     :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_confirmations_on_category_id          (category_id)
#  index_confirmations_on_term_id              (term_id)
#  index_confirmations_on_term_id_and_user_id  (term_id,user_id) UNIQUE
#  index_confirmations_on_user_id              (user_id)
#  index_confirmations_on_user_id_and_term_id  (user_id,term_id) UNIQUE
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#  term_id      (term_id => terms.id)
#  user_id      (user_id => users.id)
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
      term: old_record.term,
      category: old_record.category
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

  test 'confirmations must have a Category' do
    sample = confirmations('minimal')

    assert_predicate sample.category, :present?
    assert_predicate sample, :valid?

    sample.category = nil

    assert_not_predicate sample, :valid?
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
