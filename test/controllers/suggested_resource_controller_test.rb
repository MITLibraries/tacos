# frozen_string_literal: true

require 'test_helper'

class SuggestedResourceControllerTest < ActionDispatch::IntegrationTest
  test 'suggested resource list is not accessible without authentication' do
    get suggested_resource_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'suggested resource list is not accessible to basic users' do
    sign_in users(:basic)
    get suggested_resource_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'suggested resource list is accessible to suggestors' do
    sign_in users(:suggestor)
    get suggested_resource_path

    assert_response :success
  end

  test 'suggested resource list is accessible to admins' do
    sign_in users(:admin)
    get suggested_resource_path

    assert_response :success
  end
end
