# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # Define abilities for the user here.
  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  def initialize(user)
    return unless user.present?
    # Rules will go here.

    return unless user.admin?

    can :manage, :all
  end
end
