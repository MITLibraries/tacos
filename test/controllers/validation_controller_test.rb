# frozen_string_literal: true

require 'test_helper'

class ValidationControllerTest < ActionDispatch::IntegrationTest
  # Access to validation index
  test 'validation index is not accessible without authentication' do
    get validate_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'validation index is accessible to users with no special access' do
    sign_in users(:basic)
    get validate_path

    assert_response :success
  end

  test 'validation index is accessible to users with the admin flag set' do
    sign_in users(:admin)
    get validate_path

    assert_response :success
  end

  test 'unauthenticated users do not see a nav link to validation' do
    get root_path

    assert_select 'a.nav-item', text: 'Validate', count: 0
  end

  test 'Users with no special access do see a nav link to validation' do
    sign_in users(:basic)
    get root_path

    assert_select 'a.nav-item', text: 'Validate', count: 1
  end

  test 'Users with the admin flag set do see a nav link to validation' do
    sign_in users(:admin)
    get root_path

    assert_select 'a.nav-item', text: 'Validate', count: 1
  end

  # Access to validation form
  test 'validation form is not accessible without authentication' do
    get validate_term_path(terms(:hi))

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'validation form is accessible to users with no special access' do
    sign_in users(:basic)
    get validate_term_path(terms(:hi))

    assert_response :success
  end

  test 'validation form is accessible to users with the admin flag set' do
    sign_in users(:admin)
    get validate_term_path(terms(:hi))

    assert_response :success
  end

  # Validation form contents
  test 'validation form includes a table row for every detector' do
    sign_in users(:basic)
    get validate_term_path(terms(:hi))

    assert_select 'tr.detector-result', count: Detector.count
  end

  test 'validation form includes a table row for every category' do
    sign_in users(:basic)
    get validate_term_path(terms(:hi))

    assert_select 'tr.category-result', count: Category.count
  end
end
