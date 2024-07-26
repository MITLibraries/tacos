module FakeAuthConfig
  # Used in an initializer to determine if the application is configured and allowed to use fake authentication.
  def self.fake_auth_status
    return true if fake_auth_enabled? && app_name_pattern_match?

    false
  end

  # Default to fake auth in development unless FAKE_AUTH_ENABLED=false. This allows rake tasks to run without loading
  # ENV.
  private_class_method def self.fake_auth_enabled?
    if Rails.env.development? && ENV['FAKE_AUTH_ENABLED'].nil?
      true
    else
      ENV['FAKE_AUTH_ENABLED'] == 'true'
    end
  end

  # Checks if the current app is a Heroku pipeline app, in which case fake_auth should be enabled.
  # In test ENV we require setting a fake app name to allow for testing of the pattern.
  private_class_method def self.app_name_pattern_match?
    return true if Rails.env.development?

    review_app_pattern = /^tacos-api-pipeline-pr-\d+$/
    review_app_pattern.match(ENV.fetch('HEROKU_APP_NAME', nil)).present?
  end
end
