class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, User
    can :create, Invite
    if user.admin
      can :access, :rails_admin
      can :dashboard
    end

    if user.persisted?
      can :manage, User do |user_object|
        user_object.id == user.id
      end
    end

  end
end
