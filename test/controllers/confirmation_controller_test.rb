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

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              term_id: term.id,
              category_id: category.id,
              user_id: 1
            }
          }

    assert_response :redirect
    follow_redirect!

    assert_equal path, root_path
    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'basic users can submit confirmation form' do
    term = terms(:doi)
    category = categories(:transactional)
    user = users(:basic)

    sign_in user

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              term_id: term.id,
              category_id: category.id,
              user_id: user.id
            }
          }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.alert', text: 'Term confirmed as Transactional', count: 1
  end

  test 'admin users can submit confirmation form' do
    term = terms(:doi)
    category = categories(:transactional)
    user = users(:admin)

    sign_in user

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              term_id: term.id,
              category_id: category.id,
              user_id: user.id
            }
          }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.alert', text: 'Term confirmed as Transactional', count: 1
  end

  test 'submitting a confirmation form without all fields shows an error' do
    confirmation_count = Confirmation.count
    term = terms(:doi)
    category = categories(:flagged)
    user = users(:basic)

    sign_in user

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              category_id: category.id
            }
          }

    assert_response :redirect
    follow_redirect!

    assert_select 'div.error', text: 'Unable to finish confirming this term. Please try again, or try a different term.', count: 1
    assert_equal confirmation_count, Confirmation.count
  end

  test 'submitting a confirmation causes that term to disappear from the list' do
    user = users(:basic)
    sign_in user

    get terms_unconfirmed_path

    assert_select 'main ul li:first-child a' do |links|
      first_link = links.first
      text = first_link.text

      term = Term.find_by(phrase: text)

      post  term_confirmation_index_path(term),
            params: {
              term_id: term.id,
              confirmation: {
                term_id: term.id,
                category_id: categories(:informational).id,
                user_id: user.id
              }
            }

      assert_response :redirect
      follow_redirect!

      assert_equal path, terms_unconfirmed_path
      assert_select 'li', text:, count: 0
    end
  end

  test 'confirmation forms that flag a term get a relevant feedback message' do
    confirmation_count = Confirmation.count
    term = terms(:doi)
    category = categories(:flagged)
    user = users(:basic)

    sign_in user

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              term_id: term.id,
              category_id: category.id,
              user_id: user.id
            }
          }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.alert', text: 'Term flagged for review', count: 1
    assert_equal confirmation_count + 1, Confirmation.count
  end

  test 'confirmation forms that flag a term cause that Term to have its flag set' do
    confirmation_count = Confirmation.count
    term = terms(:doi)
    category = categories(:flagged)
    user = users(:basic)

    assert_not term.flag

    sign_in user

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              term_id: term.id,
              category_id: category.id,
              user_id: user.id
            }
          }

    assert_response :redirect
    follow_redirect!

    term.reload

    assert term.flag
    assert_equal confirmation_count + 1, Confirmation.count
  end

  test 'confirmation forms that do not flag a term do not change the Term record' do
    confirmation_count = Confirmation.count
    term = terms(:doi)
    category = categories(:transactional)
    user = users(:basic)

    assert_not term.flag

    sign_in user

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              term_id: term.id,
              category_id: category.id,
              user_id: user.id
            }
          }

    assert_response :redirect
    follow_redirect!

    term.reload

    assert_not term.flag
    assert_equal confirmation_count + 1, Confirmation.count
  end

  test 'submitting a confirmation again generates an error, but not an ugly one' do
    confirmation_count = Confirmation.count
    existing_record = confirmations(:informational)
    term = existing_record.term
    category = existing_record.category
    user = existing_record.user

    sign_in user

    post  term_confirmation_index_path(term),
          params: {
            confirmation: {
              term_id: term.id,
              category_id: category.id,
              user_id: user.id
            }
          }

    assert_response :redirect
    follow_redirect!

    assert_equal path, terms_unconfirmed_path
    assert_select 'div.error', text: 'Duplicate confirmations are not supported', count: 1
    assert_equal confirmation_count, Confirmation.count
  end
end
