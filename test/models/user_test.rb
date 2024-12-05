# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  uid        :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  admin      :boolean          default(FALSE)
#
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user valid with uid and email' do
    user = users(:valid)

    assert_predicate user.uid, :present?
    assert_predicate user.email, :present?
    assert_predicate user, :valid?
  end

  test 'user invalid without uid' do
    user = users(:valid)

    assert_predicate user, :valid?

    user.uid = nil
    user.save

    assert_not user.valid?
  end

  test 'user invalid without email' do
    user = users(:valid)

    assert_predicate user, :valid?

    user.email = nil
    user.save

    assert_not user.valid?
  end

  test 'admin user is valid' do
    user = users(:admin)

    assert_predicate user, :admin?
    assert_predicate user, :valid?
  end

  test 'non-admin user is valid' do
    user = users(:basic)

    assert_not user.admin?
    assert_predicate user, :valid?
  end

  test 'removing a user will remove their Confirmations' do
    user_count = User.count
    confirmation_count = Confirmation.count

    user = users('valid')

    relevant_links = user.confirmations.count

    assert_operator(0, :<, relevant_links)

    user.destroy

    assert_equal(user_count - 1, User.count)
    assert_equal(confirmation_count - relevant_links, Confirmation.count)
  end
end
