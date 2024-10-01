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

    can :manage, :detector__suggested_resource
    can :manage, Detector::SuggestedResource

    can :view, :report
    # End of Rules for all authenticated user with no additional roles required

    # Rules for admins
    return unless user.admin?

    can :manage, :all
  end
end
