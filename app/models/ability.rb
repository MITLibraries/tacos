# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # Define abilities for the user here.
  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  def initialize(user)
    return if user.blank?
    # Rules will go here.

    # all authenticated
    # can :view, :playground

    return unless user.admin?

    can :manage, :all
  end
end
