class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role? :student
    end

    if user.role? :teacher
      can :administrate, Exercise
      can :administrate, Workgroup
    end
  end
end