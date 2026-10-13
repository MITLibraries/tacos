# frozen_string_literal: true

require 'test_helper'

class SuggestedPatternControllerTest < ActionDispatch::IntegrationTest
  def create_new_record
    post suggested_pattern_create_path,
         params: {
           suggested_pattern: {
             title: 'Brand new pattern',
             url: 'https://www.example.org',
             shortcode: 'example',
             pattern: '(example|EXAMPLE)'
           }
         }
  end

  def update_record(id)
    patch suggested_pattern_update_path(id),
          params: {
            suggested_pattern: {
              title: 'Updated title',
              url: 'https://www.example.org/updated',
              shortcode: 'updated',
              pattern: '(updated|UPDATED)'
            }
          }
  end

  def delete_record(id)
    delete suggested_pattern_delete_path(id)
  end

  # Access tests for different user types --------------------------------------
  # - Suggested pattern list
  test 'suggested pattern list is not accessible without authentication' do
    get suggested_pattern_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'suggested pattern list is not accessible to basic users' do
    sign_in users(:basic)
    get suggested_pattern_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'suggested pattern list is accessible to suggestors' do
    sign_in users(:suggestor)
    get suggested_pattern_path

    assert_response :success
  end

  test 'suggested pattern list is accessible to admins' do
    sign_in users(:admin)
    get suggested_pattern_path

    assert_response :success
  end

  # - New suggested pattern form
  test 'new suggested pattern form is not accessible without authorization' do
    get suggested_pattern_new_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'new suggested pattern form is not accessible to basic users' do
    sign_in users(:basic)
    get suggested_pattern_new_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'new suggested pattern form is accessible to suggestors' do
    sign_in users(:suggestor)
    get suggested_pattern_new_path

    assert_response :success
  end

  test 'new suggested pattern form is accessible to admins' do
    sign_in users(:admin)
    get suggested_pattern_new_path

    assert_response :success
  end

  # - Edit suggested pattern form
  test 'edit suggested pattern form is not accessible without authorization' do
    target_record = SuggestedPattern.first
    get suggested_pattern_edit_path(target_record.id)

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'edit suggested pattern form is not accessible to basic users' do
    sign_in users(:basic)
    target_record = SuggestedPattern.first
    get suggested_pattern_edit_path(target_record.id)

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'edit suggested pattern form is accessible to suggestors' do
    sign_in users(:suggestor)
    target_record = SuggestedPattern.first
    get suggested_pattern_edit_path(target_record.id)

    assert_response :success
  end

  test 'edit suggested pattern form is accessible to admins' do
    sign_in users(:admin)
    target_record = SuggestedPattern.first
    get suggested_pattern_edit_path(target_record.id)

    assert_response :success
  end

  # - Suggested pattern create action
  test 'new suggested patterns cannot be created by basic users' do
    sign_in users(:basic)
    initial_record_count = SuggestedPattern.count

    create_new_record

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
    assert_equal initial_record_count, SuggestedPattern.count
  end

  test 'new suggested patterns can be created by suggestors' do
    sign_in users(:suggestor)
    initial_record_count = SuggestedPattern.count

    create_new_record

    follow_redirect!

    assert_equal path, suggested_pattern_path
    assert_includes @response.body, 'Suggested Pattern "Brand new pattern" created'

    assert_equal initial_record_count + 1, SuggestedPattern.count
  end

  test 'new suggested patterns can be created by admins' do
    sign_in users(:admin)
    initial_record_count = SuggestedPattern.count

    create_new_record

    follow_redirect!

    assert_equal path, suggested_pattern_path
    assert_includes @response.body, 'Suggested Pattern "Brand new pattern" created'

    assert_equal initial_record_count + 1, SuggestedPattern.count
  end

  # - Suggested pattern update action
  test 'suggested patterns cannot be updated by basic users' do
    sign_in users(:basic)

    initial_record_count = SuggestedPattern.count

    last_record = SuggestedPattern.last

    update_record(last_record.id)

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
    assert_equal initial_record_count, SuggestedPattern.count
  end

  test 'suggested patterns can be updated by suggestors' do
    sign_in users(:suggestor)
    initial_record_count = SuggestedPattern.count

    last_record = SuggestedPattern.last

    update_record(last_record.id)

    follow_redirect!

    assert_equal path, suggested_pattern_path
    assert_includes @response.body, 'Suggested Pattern "Updated title" updated'
    assert_equal initial_record_count, SuggestedPattern.count
  end

  test 'suggested patterns can be updated by admins' do
    sign_in users(:admin)
    initial_record_count = SuggestedPattern.count

    last_record = SuggestedPattern.last

    update_record(last_record.id)

    follow_redirect!

    assert_equal path, suggested_pattern_path
    assert_includes @response.body, 'Suggested Pattern "Updated title" updated'
    assert_equal initial_record_count, SuggestedPattern.count
  end

  # - Suggested pattern delete action
  test 'suggested patterns cannot be deleted by basic users' do
    sign_in users(:basic)

    initial_record_count = SuggestedPattern.count

    last_record = SuggestedPattern.last

    delete_record(last_record.id)

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
    assert_equal initial_record_count, SuggestedPattern.count
  end

  test 'suggested patterns can be deleted by suggestors' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedPattern.count

    last_record = SuggestedPattern.last

    delete_record(last_record.id)

    follow_redirect!

    assert_equal path, suggested_pattern_path
    assert_includes @response.body, "Suggested Pattern \"#{last_record.title}\" deleted"
    assert_equal initial_record_count - 1, SuggestedPattern.count
  end

  test 'suggested patterns can be deleted by admins' do
    sign_in users(:admin)

    initial_record_count = SuggestedPattern.count

    last_record = SuggestedPattern.last

    delete_record(last_record.id)

    follow_redirect!

    assert_equal path, suggested_pattern_path
    assert_includes @response.body, "Suggested Pattern \"#{last_record.title}\" deleted"
    assert_equal initial_record_count - 1, SuggestedPattern.count
  end

  # Functionality tests (all these tests use the "suggestor" role) -------------
  test 'suggested patterns cannot be created with nil values' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedPattern.count

    post  suggested_pattern_create_path,
          params: {
            suggested_pattern: {
              title: nil,
              url: nil,
              shortcode: nil,
              pattern: nil
            }
          }

    assert_redirected_to suggested_pattern_new_path
    follow_redirect!

    assert_includes @response.body, 'Suggested Pattern "" could not be created'

    assert_equal initial_record_count, SuggestedPattern.count
  end

  test 'requesting edit form for non-existent record is caught and redirected' do
    sign_in users(:suggestor)

    # Make sure we're actually looking for a non-existent record
    last_record = SuggestedPattern.last

    missing_id = last_record.id + 1
    missing = SuggestedPattern.find_by(id: missing_id)

    assert_nil missing

    get suggested_pattern_edit_path(missing_id)

    assert_redirected_to suggested_pattern_path
    follow_redirect!

    assert_includes @response.body, "Requested Suggested Pattern (id: #{missing_id}) not found"
  end

  test 'suggested patterns cannot be created with malicious urls' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedPattern.count

    post  suggested_pattern_create_path,
          params: {
            suggested_pattern: {
              title: 'malicious',
              url: 'javascript://console.log("malicious");',
              shortcode: 'malicious',
              pattern: '[\s\S]*'
            }
          }

    assert_redirected_to suggested_pattern_new_path
    follow_redirect!

    assert_includes @response.body, 'Suggested Pattern "malicious" could not be created'

    assert_equal initial_record_count, SuggestedPattern.count
  end

  test 'suggested patterns must have valid regular expressions' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedPattern.count

    post  suggested_pattern_create_path,
          params: {
            suggested_pattern: {
              title: 'malformed',
              url: 'https://example.org',
              shortcode: 'malformed',
              pattern: '[\s\\'
            }
          }

    assert_redirected_to suggested_pattern_new_path
    follow_redirect!

    assert_includes @response.body, 'Suggested Pattern "malformed" could not be created'

    assert_equal initial_record_count, SuggestedPattern.count
  end

  test 'suggested patterns cannot be updated to have nil values' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedPattern.count
    target_record = SuggestedPattern.last

    assert_not_equal target_record.title, nil

    patch suggested_pattern_update_path(target_record.id),
          params: {
            suggested_pattern: {
              title: nil,
              url: nil,
              shortcode: nil,
              pattern: nil
            }
          }

    assert_redirected_to suggested_pattern_path
    follow_redirect!

    assert_includes @response.body, "Suggested Pattern \"#{target_record.title}\" could not be updated"

    assert_equal initial_record_count, SuggestedPattern.count
  end
end
