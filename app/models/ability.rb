# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # Define abilities for the user here.
  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  def initialize(user)
    # Actions allowed for non-authenticated Users should add `skip_before_action :require_user`

    # Start of Rules for all authenticated user with no additional roles required
    return if user.blank?

    # Allow all authenticated users to performa all CRUD actions on Suggested Resources
    can :manage, :detector__suggested_resource
    can :manage, Detector::SuggestedResource

    # Allow all authenticated users to view the Categorization index and show dashboards
    can %w[index show], :categorization
    can :read, Categorization

    # Allow all authenticated users to view reports
    can :view, :report
    # End of Rules for all authenticated user with no additional roles required

    # Rules for admins
    return unless user.admin?

    can :manage, :all
  end
end
