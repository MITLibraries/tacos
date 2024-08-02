# Handles authentication response from Omniauth. See
# [the Devise docs](https://www.rubydoc.info/gems/devise_token_auth/DeviseTokenAuth/OmniauthCallbacksController) for
# additional information about this controller.
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include FakeAuthConfig

  def openid_connect
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user, event: :authentication
    flash[:notice] = "Welcome, #{@user.email}!"
  end

  # Developer authentication is used in local dev and PR builds.
  def developer
    raise 'Invalid Authentication' unless FakeAuthConfig.fake_auth_enabled?

    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user, event: :authentication
    flash[:notice] = "Welcome, #{@user.email}!"
  end
end
