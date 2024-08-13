# frozen_string_literal: true

require 'test_helper'

class FakeAuthTest < ActiveSupport::TestCase
  include FakeAuthConfig

  test 'fakeauth disabled' do
    ClimateControl.modify(
      FAKE_AUTH_ENABLED: 'false'
    ) do
      assert_not_predicate(FakeAuthConfig, :fake_auth_enabled?)
    end
  end

  test 'fakeauth disabled pr apps' do
    ClimateControl.modify(
      FAKE_AUTH_ENABLED: 'false',
      HEROKU_APP_NAME: 'tacos-api-pipeline-pr-1'
    ) do
      assert_not_predicate(FakeAuthConfig, :fake_auth_enabled?)
    end
  end

  test 'fakeauth enabled PR apps' do
    ClimateControl.modify(
      FAKE_AUTH_ENABLED: 'true',
      HEROKU_APP_NAME: 'tacos-api-pipeline-pr-1'
    ) do
      assert_predicate(FakeAuthConfig, :fake_auth_enabled?)
    end
    ClimateControl.modify(
      FAKE_AUTH_ENABLED: 'true',
      HEROKU_APP_NAME: 'tacos-api-pipeline-pr-500'
    ) do
      assert_predicate(FakeAuthConfig, :fake_auth_enabled?)
    end
  end

  test 'fakeauth enabled no HEROKU_APP_NAME' do
    ClimateControl.modify FAKE_AUTH_ENABLED: 'true' do
      assert_not_predicate(FakeAuthConfig, :fake_auth_enabled?)
    end
  end

  test 'fakeauth enabled production app name' do
    ClimateControl.modify FAKE_AUTH_ENABLED: 'true',
                          HEROKU_APP_NAME: 'tacos-prod' do
      assert_not_predicate(FakeAuthConfig, :fake_auth_enabled?)
    end
  end

  test 'fakeauth enabled staging app name' do
    ClimateControl.modify FAKE_AUTH_ENABLED: 'true',
                          HEROKU_APP_NAME: 'tacos-stage' do
      assert_not_predicate(FakeAuthConfig, :fake_auth_enabled?)
    end
  end
end
