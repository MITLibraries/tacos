# frozen_string_literal: true

require 'test_helper'

class TermControllerTest < ActionDispatch::IntegrationTest
  test 'confirmation index is not accessible without authentication' do
    get terms_unconfirmed_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'confirmation index is accessible to basic users when authenticated' do
    sign_in users(:basic)
    get terms_unconfirmed_path

    assert_response :success
  end

  test 'confirmation index is accessible to admin users when authenticated' do
    sign_in users(:admin)
    get terms_unconfirmed_path

    assert_response :success
  end
end
