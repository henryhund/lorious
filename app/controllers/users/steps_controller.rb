class Users::StepsController < ApplicationController

  def edit
    @user = current_user
    @user.initialize_steps if @user.current_step.nil?
  end

  def update
    @user = current_user
    @user.update_attributes user_params
    current_step_index = params[:current_step_index].to_i
    @user.current_step ||= @user.steps[current_step_index]
    if @user.current_step == "profile_info" && !params.has_key?(:apply_to_be_an_expert)
      redirect_to root_url, notice: "Registration complete"
    else
      @user.current_step = @user.steps[current_step_index + 1]
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :website, :username, :tag_line, :bio, :location, :step_1_complete, :step_2_complete)
  end

end
