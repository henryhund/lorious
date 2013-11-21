class UsersController < ApplicationController

  load_and_authorize_resource

  def show
    @user = current_user
    @available_skills = AvailableTag.skills.map { |e| [e.name, e.name] }
    authorize! :edit, @user
  end

  def cancel_application
    if params[:id].present?
      User.find(params[:id]).update_attributes(:is_expert_applied => false)
      flash[:notice] = "Succesfully cancelled Expert application."  
    end
    redirect_to users_path
  end
end
