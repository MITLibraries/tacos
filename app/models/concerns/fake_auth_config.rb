# frozen_string_literal: true

module FakeAuthConfig
  # Used in an initializer to determine if the application is configured and allowed to use fake authentication.
  def self.fake_auth_enabled?
    fake_auth_env? && app_name_pattern_match?
  end

  # Default to fake auth in development unless FAKE_AUTH_ENABLED=false. This allows rake tasks to run without loading
  # ENV.
  private_class_method def self.fake_auth_env?
    if Rails.env.development? && ENV['FAKE_AUTH_ENABLED'].nil?
      true
    else
      ENV['FAKE_AUTH_ENABLED'] == 'true'
    end
  end

  # Check if the app is a PR build. This assures that fake auth is never enabled in staging or prod.
  private_class_method def self.app_name_pattern_match?
    return true if Rails.env.development?

    review_app_pattern = /^tacos-api-pipeline-pr-\d+$/
    review_app_pattern.match(ENV.fetch('HEROKU_APP_NAME', nil)).present?
  end
end
