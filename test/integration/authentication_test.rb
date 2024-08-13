# frozen_string_literal: true

require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    auth_setup
  end

  def teardown
    auth_teardown
  end

  def silence_omniauth
    previous_logger = OmniAuth.config.logger
    OmniAuth.config.logger = Logger.new('/dev/null')
    yield
  ensure
    OmniAuth.config.logger = previous_logger
  end

  test 'accessing callback with bad credentials does not create a new user' do
    user_count = User.count
    OmniAuth.config.mock_auth[:openid_connect] = :invalid_credentials
    silence_omniauth do
      get '/users/auth/openid_connect/callback'
      follow_redirect!
    end

    assert_response :success
    assert_equal(user_count, User.count)
  end

  test 'new users can authenticate' do
    OmniAuth.config.mock_auth[:openid_connect] =
      OmniAuth::AuthHash.new(provider: 'openid_connect',
                             uid: '123545',
                             extra: { raw_info: { preferred_username: '123545', email: 'test@us.er' } })
    user_count = User.count
    get '/users/auth/openid_connect/callback'
    follow_redirect!

    assert_response :success
    assert_equal(user_count + 1, User.count)
  end

  test 'existing users can authenticate' do
    user_count = User.count
    mock_auth(users(:valid))
    follow_redirect!

    assert_response :success
    assert_equal(user_count, User.count)
  end
end
