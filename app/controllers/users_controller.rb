class UsersController < ApplicationController

  load_and_authorize_resource

  def show
    @user = current_user
    @available_skills = AvailableTag.skills.map { |e| [e.name, e.name] }
    authorize! :edit, @user
  end

end
