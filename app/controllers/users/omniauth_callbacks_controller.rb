class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def openid_connect
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user, event: :authentication
  end

  # def developer
  #   @user = User.from_omniauth(request.env['omniauth.auth'])
  #   sign_in_and_redirect @user, event: :authentication
  # end
end
