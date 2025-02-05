# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.lcov_file_name = 'coverage.lcov'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
]
SimpleCov.start('rails')

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock

  # Filter TACOS email. It's not sensitive, but keeping it out of code is still good practice to avoid spam
  config.filter_sensitive_data('FAKE_TACOS_EMAIL') do
    ENV.fetch('TACOS_EMAIL', nil).to_s
  end

  # Filter Libkey Key
  config.filter_sensitive_data('FAKE_LIBKEY_KEY') do
    ENV.fetch('LIBKEY_KEY', nil).to_s
  end
  # Filter LibKey ID
  config.filter_sensitive_data('FAKE_LIBKEY_ID') do
    ENV.fetch('LIBKEY_ID', nil).to_s
  end

  config.before_record do |interaction|
    header = interaction.response&.headers&.[]('Report-To')
    header&.each do |redacted_text|
      interaction.filter!(redacted_text, '<REDACTED_REPORT_TO>')
    end

    header = interaction.response&.headers&.[]('Reporting-Endpoints')
    header&.each do |redacted_text|
      interaction.filter!(redacted_text, '<REDACTED_REPORTING_ENDPOINT>')
    end

    header = interaction.response&.headers&.[]('Nel')
    header&.each do |redacted_text|
      interaction.filter!(redacted_text, '<REDACTED_NEL>')
    end

    header = interaction.response&.headers&.[]('Set-Cookie')
    header&.each do |redacted_text|
      interaction.filter!(redacted_text, '<FAKE_COOKIE_DATA>')
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end

module ActiveSupport
  class TestCase
    SQLite3::ForkSafety.suppress_warnings!

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def mock_auth(user)
      OmniAuth.config.mock_auth[:openid_connect] =
        OmniAuth::AuthHash.new(provider: 'openid_connect',
                               uid: user.uid,
                               extra: { raw_info: { preferred_username: user.uid, email: user.email } })
      get '/users/auth/openid_connect/callback'
    end

    def auth_setup
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
      Rails.application.env_config['omniauth.auth'] =
        OmniAuth.config.mock_auth[:openid_connect]
      OmniAuth.config.test_mode = true
    end

    def auth_teardown
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:openid_connect] = nil
    end
  end
end
