class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, User
    can :create, Invite

    if user.admin
      can :access, :rails_admin
      can :dashboard
      can :manage, :all
    elsif user.persisted?

      can :manage, User do |user_object|
        user_object.id == user.id
      end

      can :manage, Appointment do |appt_object|
        appt_object.expert == user || appt_object.user == user
      end

      can :manage, Request do |req_obj|
        req_obj.requester == user
      end
    end

  end
end
