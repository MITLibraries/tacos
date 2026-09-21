# frozen_string_literal: true

require 'test_helper'

class SuggestedResourceControllerTest < ActionDispatch::IntegrationTest
  def create_new_record
    post suggested_resource_create_path,
         params: {
           suggested_resource: {
             title: 'Brand new resource',
             url: 'https://www.example.org'
           }
         }
  end

  def update_record(id)
    patch suggested_resource_update_path(id),
          params: {
            suggested_resource: {
              title: 'Updated title',
              url: 'https://www.example.org'
            }
          }
  end

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

  test 'new suggested resources cannot be created by basic users' do
    sign_in users(:basic)
    initial_record_count = SuggestedResource.count

    create_new_record

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
    assert_equal initial_record_count, SuggestedResource.count
  end

  test 'new suggested resources can be created by suggestors' do
    sign_in users(:suggestor)
    initial_record_count = SuggestedResource.count

    create_new_record

    follow_redirect!

    assert_equal path, suggested_resource_path
    assert_includes @response.body, 'Suggested Resource "Brand new resource" created'

    assert_equal initial_record_count + 1, SuggestedResource.count
  end

  test 'suggested resources cannot be updated by basic users' do
    sign_in users(:basic)

    initial_record_count = SuggestedResource.count

    last_record = SuggestedResource.last

    update_record(last_record.id)

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
    assert_equal initial_record_count, SuggestedResource.count
  end

  test 'suggested resources can be updated by suggestors' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedResource.count

    last_record = SuggestedResource.last

    update_record(last_record.id)

    follow_redirect!

    assert_equal path, suggested_resource_path
    assert_includes @response.body, 'Suggested Resource "Updated title" updated'
    # No new records were created
    assert_equal initial_record_count, SuggestedResource.count
  end
end
