# frozen_string_literal: true

require 'test_helper'

class NavTest < ActionDispatch::IntegrationTest
  def setup
    auth_setup
  end

  def teardown
    auth_teardown
  end

  test 'Unauthenticated user navigation' do
    get root_path

    assert_select 'nav' do
      assert_select 'a[href=?]', root_path

      # Unauthenticated users do not see:
      assert_select 'a[href=?]', suggestions_path, count: 0
      assert_select 'a[href=?]', admin_root_path, count: 0
    end
  end

  test 'Basic user navigation' do
    mock_auth(users(:basic))
    get root_path

    assert_select 'nav' do
      assert_select 'a[href=?]', root_path
      assert_select 'a[href=?]', admin_root_path

      # Basic users do not see:
      assert_select 'a[href=?]', suggestions_path, count: 0
    end
  end

  test 'Suggestors navigation' do
    mock_auth(users(:suggestor))
    get root_path

    assert_select 'nav' do
      assert_select 'a[href=?]', root_path
      assert_select 'a[href=?]', suggestions_path
      assert_select 'a[href=?]', admin_root_path

      # Suggestors do not see:
    end
  end

  test 'Admins navigation' do
    mock_auth(users(:admin))
    get root_path

    assert_select 'nav' do
      assert_select 'a[href=?]', root_path
      assert_select 'a[href=?]', suggestions_path
      assert_select 'a[href=?]', admin_root_path

      # Admins do not see:
    end
  end
end
