# frozen_string_literal: true

require 'test_helper'

class TermControllerTest < ActionDispatch::IntegrationTest
  test 'confirmation index is not accessible without authentication' do
    get confirm_index_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'confirmation index is accessible to basic users when authenticated' do
    sign_in users(:basic)
    get confirm_index_path

    assert_response :success
  end

  test 'confirmation index is accessible to admin users when authenticated' do
    sign_in users(:admin)
    get confirm_index_path

    assert_response :success
  end

  test 'confirmation form is not accessible without authentication' do
    get confirm_term_path(terms(:doi))

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'confirmation form is accessible to basic users when authenticated' do
    sign_in users(:basic)
    get confirm_term_path(terms(:doi))

    assert_response :success
  end

  test 'confirmation form is accessible to admin users when authenticated' do
    sign_in users(:admin)
    get confirm_term_path(terms(:doi))

    assert_response :success
  end
end
