# frozen_string_literal: true

Sentry.init do |config|
  return unless ENV.has_key?('SENTRY_DSN')
  config.rails.structured_logging.enabled = true
  config.dsn = ENV.fetch('SENTRY_DSN')
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.environment = ENV.fetch('SENTRY_ENV', 'unknown')
end
