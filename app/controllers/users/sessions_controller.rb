class Users::SessionsController < Devise::SessionsController
  skip_before_action :profile_not_completed
  def new
    redirect_to root_path
  end

end