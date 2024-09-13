# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Mitlibraries::Theme::Engine.helpers
  before_action :require_user
  skip_before_action :require_user, only: :new_session_path

  rescue_from CanCan::AccessDenied do
    redirect_to root_path, alert: 'Not authorized.'
  end

  def new_session_path(_scope)
    root_path
  end

  private

  def require_user
    return if current_user

    redirect_to root_path, alert: 'Please sign in to continue'
  end
end
