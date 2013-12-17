class Users::RegistrationsController < Devise::RegistrationsController
  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(user_params)
    else
      # remove the virtual current_password attribute update_without_password
      # doesn't know how to ignore it
      user_params.delete(:current_password)
      @user.update_without_password(user_params)
      
      if @user.save! 
        if @user.expert?
          if params[:expert][:skills].present?
            @user.skill_list = []
            @user.skill_list.add params[:expert][:skills]
            @user.save validate: false
          end
          
          if params[:expert][:subscriptions].present?
            @user.subscription_list = []
            @user.subscription_list.add params[:expert][:subscriptions]
            @user.save validate: false
          end
          
          if params[:expert][:hourly_cost].present? && @user.availability.present?
            @availability = @user.availability
            @availability.hourly_cost = params[:expert][:hourly_cost]
            @availability.save
          end
        end
        true
      else
        false      
      end  
        
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "users/show"
    end
  end

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    false
  end

  def user_params
    require_params = @user.expert? ? params.require(:expert) : params.require(:user)
    require_params.permit(:subscription_list, :first_name, :last_name, :zip_code, :website, :username, :tag_line, :bio, :location, :job, :image)
  end
end
