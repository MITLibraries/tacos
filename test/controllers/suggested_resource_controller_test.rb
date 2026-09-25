# frozen_string_literal: true

require 'test_helper'

class SuggestedResourceControllerTest < ActionDispatch::IntegrationTest
  def create_bare_record
    post  suggested_resource_create_path,
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

  # Access tests for different user types --------------------------------------
  # - Suggested resource list
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

  # - New suggested resource form
  test 'new suggested resource form is not accessible without authorization' do
    get suggested_resource_new_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'new suggested resource form is not accessible to basic users' do
    sign_in users(:basic)
    get suggested_resource_new_path

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'new suggested resource form is accessible to suggestors' do
    sign_in users(:suggestor)
    get suggested_resource_new_path

    assert_response :success
  end

  test 'new suggested resource form is accessible to admins' do
    sign_in users(:admin)
    get suggested_resource_new_path

    assert_response :success
  end

  # - Edit suggested resource form
  test 'edit suggested resource form is not accessible without authorization' do
    target_record = SuggestedResource.first
    get suggested_resource_edit_path(target_record.id)

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'edit suggested resource form is not accessible to basic users' do
    sign_in users(:basic)
    target_record = SuggestedResource.first
    get suggested_resource_edit_path(target_record.id)

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end

  test 'edit suggested resource form is accessible to suggestors' do
    sign_in users(:suggestor)
    target_record = SuggestedResource.first
    get suggested_resource_edit_path(target_record.id)

    assert_response :success
  end

  test 'edit suggested resource form is accessible to admins' do
    sign_in users(:admin)
    target_record = SuggestedResource.first
    get suggested_resource_edit_path(target_record.id)

    assert_response :success
  end

  # - Suggested resource create action
  test 'new suggested resources cannot be created by basic users' do
    sign_in users(:basic)
    initial_record_count = SuggestedResource.count

    create_bare_record

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
    assert_equal initial_record_count, SuggestedResource.count
  end

  test 'new suggested resources can be created by suggestors' do
    sign_in users(:suggestor)
    initial_record_count = SuggestedResource.count

    create_bare_record

    follow_redirect!

    assert_equal path, suggested_resource_path
    assert_includes @response.body, 'Suggested Resource "Brand new resource" created'

    assert_equal initial_record_count + 1, SuggestedResource.count
  end

  test 'new suggested resources can be created by admins' do
    sign_in users(:admin)
    initial_record_count = SuggestedResource.count

    create_bare_record

    follow_redirect!

    assert_equal path, suggested_resource_path
    assert_includes @response.body, 'Suggested Resource "Brand new resource" created'

    assert_equal initial_record_count + 1, SuggestedResource.count
  end

  # - Suggested resource update action
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

  test 'suggested resources can be updated by admins' do
    sign_in users(:admin)

    initial_record_count = SuggestedResource.count

    last_record = SuggestedResource.last

    update_record(last_record.id)

    follow_redirect!

    assert_equal path, suggested_resource_path
    assert_includes @response.body, 'Suggested Resource "Updated title" updated'
    # No new records were created
    assert_equal initial_record_count, SuggestedResource.count
  end

  # Functionality tests (all these tests use the "suggestor" role) -------------
  test 'suggested resources cannot be created with nil values' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedResource.count

    post  suggested_resource_create_path,
          params: {
            suggested_resource: {
              title: nil,
              url: nil
            }
          }

    assert_redirected_to suggested_resource_new_path
    follow_redirect!

    assert_includes @response.body, 'Suggested Resource "" could not be created'

    assert_equal initial_record_count, SuggestedResource.count
  end

  test 'suggested resources cannot be updated to have nil values' do
    sign_in users(:suggestor)

    target_record = SuggestedResource.last

    assert_not_equal target_record.title, nil

    patch suggested_resource_update_path(target_record.id),
          params: {
            suggested_resource: {
              title: nil,
              url: nil
            }
          }

    assert_redirected_to suggested_resource_path
    follow_redirect!

    assert_includes @response.body, "Suggested Resource \"#{target_record.title}\" could not be updated"
    assert_equal target_record, SuggestedResource.last
  end

  test 'suggested resources can be created with a term' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedResource.count
    initial_term_count = Term.count

    post  suggested_resource_create_path,
          params: {
            suggested_resource: {
              title: 'Resource with terms',
              url: 'https://www.example.org'
            },
            term: {
              append: [
                'some search string',
                'some other search string'
              ]
            }
          }

    follow_redirect!

    assert_equal path, suggested_resource_path
    assert_includes @response.body, 'Suggested Resource "Resource with terms" created'

    assert_equal initial_record_count + 1, SuggestedResource.count
    assert_equal initial_term_count + 2, Term.count
  end

  test 'blank search strings are filtered out during creation' do
    sign_in users(:suggestor)

    initial_record_count = SuggestedResource.count
    initial_term_count = Term.count

    post  suggested_resource_create_path,
          params: {
            suggested_resource: {
              title: 'Resource with terms',
              url: 'https://www.example.org'
            },
            term: {
              append: [
                'some search string',
                ' '
              ]
            }
          }

    follow_redirect!

    assert_equal path, suggested_resource_path
    assert_includes @response.body, 'Suggested Resource "Resource with terms" created'

    assert_equal initial_record_count + 1, SuggestedResource.count
    assert_equal initial_term_count + 1, Term.count
  end

  test 'suggested resources can have their terms removed' do
    sign_in users(:suggestor)

    last_record = SuggestedResource.last
    last_record_term_count = last_record.terms.count
    last_term_id = last_record.terms.last.id

    # This record needs to have at least one term
    assert_operator last_record.terms.count, :>, 0

    initial_record_count = SuggestedResource.count
    initial_term_count = Term.count

    patch suggested_resource_update_path(last_record.id),
          params: {
            suggested_resource: {
              title: last_record.title,
              url: last_record.url
            },
            term: {
              delete: [
                last_term_id
              ]
            }
          }

    follow_redirect!

    assert_includes @response.body, "Suggested Resource \"#{last_record.title}\" updated"

    # Same number of SuggestedResources
    assert_equal initial_record_count, SuggestedResource.count
    # Same number of Terms overall
    assert_equal initial_term_count, Term.count
    # This SuggestedResource has one fewer Term
    assert_equal last_record_term_count - 1, last_record.terms.count
  end
end
