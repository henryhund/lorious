class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_no_cache, :profile_not_completed
   before_filter :current_user, :cors_preflight_check
  after_filter :cors_set_access_control_headers

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
  
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"
  end

# If this is a preflight OPTIONS request, then short-circuit the
# request, return only the necessary headers and return an empty
# text/plain.

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = '*'
      headers['Access-Control-Max-Age'] = '1728000'
      #render :text => '', :content_type => 'text/plain'
    end
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
