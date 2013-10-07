class Users::StepsController < ApplicationController

  def edit
    @user = current_user
    @user.initialize_steps if @user.current_step.nil?
  end

  def update
    @user = current_user
    current_step_index = params[:current_step_index].to_i
    @user.current_step ||= @user.steps[current_step_index]
    if @user.apply_for_expert_page?
      @user.update_attributes expert_params
      @user.skill_list.add comma_seperated_string_to_array(expert_params[:skills])
      @user.save
    else
      @user.update_attributes user_params
    end
    if (@user.profile_info_page? && !params.has_key?(:apply_to_be_an_expert)) || @user.apply_for_expert_page?
      redirect_to root_url, notice: "Registration complete"
    else
      @user.current_step = @user.steps[current_step_index + 1]
      if @user.apply_for_expert_page?
        @user = @user.change_to_expert_and_return_user!
        @user.current_step = @user.steps.last
      end
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :website, :username, :tag_line, :bio, :location, :step_1_complete, :step_2_complete)
  end

  def expert_params
    params.require(:expert).permit(:skills, :job)
  end

end
