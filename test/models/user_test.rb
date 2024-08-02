# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  uid        :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test 'user valid with uid and email' do
    user = users(:valid)
    assert user.uid.present?
    assert user.email.present?
    assert user.valid?
  end

  test 'user invalid without uid' do
    user = users(:valid)
    assert user.valid?

    user.uid = nil
    user.save
    assert_not user.valid?
  end

  test 'user invalid without email' do
    user = users(:valid)
    assert user.valid?

    user.email = nil
    user.save
    assert_not user.valid?
  end
end
