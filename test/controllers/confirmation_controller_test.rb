# frozen_string_literal: true

require 'test_helper'

class ConfirmationControllerTest < ActionDispatch::IntegrationTest
  # Accessing confirmation form
  test 'confirmation form is not accessible without authentication' do
    get new_term_confirmation_path(terms(:doi))

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'confirmation form is accessible to basic users when authenticated' do
    sign_in users(:basic)
    get new_term_confirmation_path(terms(:doi))

    assert_response :success
  end

  test 'confirmation form is accessible to admin users when authenticated' do
    sign_in users(:admin)
    get new_term_confirmation_path(terms(:doi))

    assert_response :success
  end

  # Submitting confirmation form
  test 'anonymous users cannot submit confirmation form' do
    term = terms(:doi)
    category = categories(:transactional)

    post term_confirmation_index_path(term),
         params: {
           term_id: term.id,
           confirmation: { category_id: category.id }
         }

    assert_response :redirect
    follow_redirect!

    assert_equal path, root_path
    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'basic users can submit confirmation form' do
    term = terms(:doi)
    category = categories(:transactional)

    sign_in users(:basic)

    post term_confirmation_index_path(term),
         params: {
           term_id: term.id,
           confirmation: { category_id: category.id }
         }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.alert', text: 'Term confirmed as Transactional', count: 1
  end

  test 'admin users can submit confirmation form' do
    term = terms(:doi)
    category = categories(:transactional)

    sign_in users(:admin)

    post term_confirmation_index_path(term),
         params: {
           term_id: term.id,
           confirmation: { category_id: category.id }
         }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.alert', text: 'Term confirmed as Transactional', count: 1
  end

  test 'submitting a confirmation causes that term to disappear from the list' do
    sign_in users(:basic)

    get terms_unconfirmed_path

    assert_select 'main ul li:first-child a' do |links|
      first_link = links.first
      text = first_link.text

      term = Term.find_by(phrase: text)

      post term_confirmation_index_path(term),
           params: {
             term_id: term.id,
             confirmation: { category_id: categories(:informational).id }
           }

      assert_response :redirect
      follow_redirect!

      assert_equal path, terms_unconfirmed_path
      assert_select 'li', text:, count: 0
    end
  end

  test 'confirmation forms that flag a term get a relevant feedback message' do
    term = terms(:doi)
    category = categories(:flagged)

    sign_in users(:basic)

    post term_confirmation_index_path(term),
         params: {
           term_id: term.id,
           confirmation: { category_id: category.id }
         }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.alert', text: 'Term flagged for review', count: 1
  end

  test 'confirmation forms that flag a term cause that Term to have its flag set' do
    term = terms(:doi)
    category = categories(:flagged)

    assert_not term.flag

    sign_in users(:basic)

    post term_confirmation_index_path(term),
         params: {
           term_id: term.id,
           confirmation: { category_id: category.id }
         }

    assert_response :redirect
    follow_redirect!

    term.reload

    assert term.flag
  end

  test 'confirmation forms that do not flag a term do not change the Term record' do
    term = terms(:doi)
    category = categories(:transactional)

    assert_not term.flag

    sign_in users(:basic)

    post term_confirmation_index_path(term),
         params: {
           term_id: term.id,
           confirmation: { category_id: category.id }
         }

    assert_response :redirect
    follow_redirect!

    term.reload

    assert_not term.flag
  end

  test 'submitting a confirmation again generates an error, but not an ugly one' do
    existing_record = confirmations(:informational)
    term = existing_record.term
    category = existing_record.category
    user = existing_record.user

    sign_in user

    post term_confirmation_index_path(term),
         params: {
           term_id: term.id,
           confirmation: { category_id: category.id }
         }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.error', text: 'Duplicate confirmations are not supported', count: 1
  end
end
