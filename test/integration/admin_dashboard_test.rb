# frozen_string_literal: true

require 'test_helper'

class AdminDashboardTest < ActionDispatch::IntegrationTest
  def setup
    auth_setup
  end

  def teardown
    auth_teardown
  end

  test 'admin area redirects to root with prompt to sign in if not already signed in' do
    get '/admin'

    assert_response :redirect
    follow_redirect!

    assert_equal '/', path
    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'authenticated users without admin status can access admin area' do
    mock_auth(users(:basic))
    get '/admin'

    assert_response :ok
    assert_equal '/admin', path
  end

  test 'admin users can access admin area' do
    mock_auth(users(:admin))
    get '/admin'

    assert_response :ok
    assert_equal '/admin', path
  end
end
