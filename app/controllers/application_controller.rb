# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Mitlibraries::Theme::Engine.helpers

  rescue_from CanCan::AccessDenied do
    redirect_to root_path, alert: 'Not authorized.'
  end

  def new_session_path(_scope)
    root_path
  end
end
