class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, User
    if user.persisted?
      can :manage, User do |user_object|
        user_object.id == user.id
      end
    end

  end
end
