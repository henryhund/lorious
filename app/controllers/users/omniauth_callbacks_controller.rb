class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], request.env["omniauth.params"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in @user, :event => :authentication
      if !@user.step_1_complete
        session[:current_step] = "user_info"
        redirect_to edit_users_step_url(@user)
      elsif !@user.step_2_complete
        session[:current_step] = "profile_info"
        redirect_to edit_users_step_url(@user)
      else
        redirect_to users_url
      end
    else
      redirect_to root_url, notice: I18n.t("devise.omniauth_callbacks.failure")
    end
  end

  def facebook
    social_media_updated = current_user.update_social_media_for "facebook", request.env["omniauth.auth"].extra.raw_info.link, request.env["omniauth.auth"]
    redirect_to profile_url, notice: set_notice(social_media_updated, "facebook")
  end

  def twitter
    social_media_updated = current_user.update_social_media_for "twitter", request.env["omniauth.auth"].extra.raw_info.link, request.env["omniauth.auth"]
    redirect_to profile_url, notice: set_notice(social_media_updated, "twitter")
  end

  def linkedin
    social_media_updated = current_user.update_social_media_for "linkedin", request.env["omniauth.auth"].extra.raw_info.publicProfileUrl, request.env["omniauth.auth"]
    redirect_to profile_url, notice: set_notice(social_media_updated, "linkedin")
  end

  def stackexchange
    
  end

  def twitter
    
  end

  private

  def set_notice saved, provider
    saved ? "Added #{provider} to your profile" : "Failed to add #{provider} to your profile"
  end

end
