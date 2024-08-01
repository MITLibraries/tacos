Devise.setup do |config|
  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'
  require "#{Rails.root}/app/models/concerns/fake_auth_config.rb"

  config.sign_out_via = :delete

  if FakeAuthConfig.fake_auth_enabled?
    config.omniauth :developer
  else
    # OIDC configuration
    config.omniauth :openid_connect, {
      name: :openid_connect,
      scope: ['openid', 'email', 'profile'],
      claims: ['name', 'nickname', 'preferred_username', 'given_name', 'middle_name', 'family_name', 'email', 'profile'],
      issuer: ENV['OPENID_ISSUER'],
      discovery: true,
      response_type: :code,
      uid_field: 'kerberos_id',
      client_options: {
        host: ENV['OPENID_HOST'],
        identifier: ENV['OPENID_CLIENT_ID'],
        secret: ENV['OPENID_CLIENT_SECRET'],
        redirect_uri: [ENV['BASE_URL'], '/users/auth/openid_connect/callback'].join
      },
    }
  end
end
