# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :require_user
    before_action :authorize_user

    private

    def authorize_user
      return if authorize_action?(resource_name, action_name)
      
      redirect_to root_path, alert: 'Not authorized'
    end

    def authorize_action?(resource, action)
      can? action, resource
    end

    def require_user
      return if current_user
      
      redirect_to root_path, alert: 'Please sign in to continue'
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
