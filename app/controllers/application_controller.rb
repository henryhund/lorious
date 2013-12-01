class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_no_cache, :profile_not_completed
   

  rescue_from CanCan::AccessDenied do |exception|
   redirect_to '/', :alert => exception.message
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end
  
  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  def profile_not_completed
    @user = current_user
    if @user.present?
        if !@user.step_1_complete
          session[:current_step] = "user_info"
          flash[:alert] = "Please complete your profile information before using the application."
          redirect_to edit_users_step_url(@user)
        elsif !@user.step_2_complete
          session[:current_step] = "profile_info"
          flash[:alert] = "Please complete your profile information before using the application."
          redirect_to edit_users_step_url(@user)
        end
    end 
  end
end
