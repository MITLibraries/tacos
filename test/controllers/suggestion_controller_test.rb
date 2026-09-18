# frozen_string_literal: true

require 'test_helper'

class SuggestionControllerTest < ActionDispatch::IntegrationTest
  test 'suggestion dashboard is not accessible without authentication' do
    get suggestions_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'suggestion dashboard is not accessible to basic users' do
    sign_in users(:basic)
    get suggestions_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'suggestion dashboard is accessible to suggestors' do
    sign_in users(:suggestor)
    get suggestions_path

    assert_response :success
  end

  test 'suggestion dashboard is accessible to admins' do
    sign_in users(:admin)
    get suggestions_path

    assert_response :success
  end
end
