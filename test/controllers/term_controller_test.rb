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

  test 'basic users see only one confirmation option' do
    sign_in users(:basic)
    get terms_unconfirmed_path

    assert_select 'p.wrap-filters', text: "View: Categorized terms All terms", count: 0
  end

  test 'admin users see two confirmation options' do
    sign_in users(:admin)
    get terms_unconfirmed_path

    assert_select 'p.wrap-filters', text: "View: Categorized terms All terms", count: 1
  end

  test 'basic users cannot access the confirmation option for uncategorized terms' do
    sign_in users(:basic)
    get terms_unconfirmed_path(show: 'all')

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'admin users can access the confirmation option for uncategorized terms' do
    sign_in users(:admin)
    get terms_unconfirmed_path(show: 'all')

    assert_response :success
  end

  test 'confirmation index can show two different sets of terms for admin users' do
    sign_in users(:admin)
    get terms_unconfirmed_path

    # default_pagy will be something like "Displaying 10 items"
    default_pagy = response.parsed_body.xpath('//main//span').first.text
    default_pagy_count = default_pagy.split.second.to_i

    get terms_unconfirmed_path(show: 'all')

    # The '?type=all' route asks for more records, so the count should be higher
    all_pagy = response.parsed_body.xpath('//main//span').first.text
    all_pagy_count = all_pagy.split.second.to_i

    assert_operator all_pagy_count, :>, default_pagy_count
  end
end
