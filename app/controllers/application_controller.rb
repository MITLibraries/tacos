class ApplicationController < ActionController::Base
  helper Mitlibraries::Theme::Engine.helpers

  def new_session_path(_scope)
    root_path
  end
end
