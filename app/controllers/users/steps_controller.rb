class Users::StepsController < ApplicationController

  def edit
    @user = current_user
    @user.current_step = session[:current_step] || @user.steps.first
    session[:current_step] = nil
    @user.initialize_steps if @user.current_step.nil?
  end

  def update
    @user = current_user
    current_step_index = params[:current_step_index].to_i
    @user.current_step ||= @user.steps[current_step_index]
    if @user.apply_for_expert_page?
      # @user.attributes = expert_params
      @user.skill_list.add params[:user][:skills] if params[:user][:skills]
      @user.about_description = params[:user][:about_description]
      @user.save validate: false
    else
      @user.update_attributes user_params
    end
    if (@user.profile_info_page? && !params.has_key?(:apply_to_be_an_expert)) || @user.apply_for_expert_page?
      redirect_to root_url, notice: "Registration complete"
    else
      @user.current_step = @user.steps[current_step_index + 1]
      if @user.apply_for_expert_page?
        @user.is_expert_applied = true
        @user.save
        @user.current_step = @user.steps.last
        @available_skills = AvailableTag.skills.map { |e| [e.name, e.name] }
      end
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :website, :username, :tag_line, :bio, :location, :step_1_complete, :step_2_complete, :image, :job)
  end

  def expert_params
    params.require(:expert)#.permit(:job)
  end

end
