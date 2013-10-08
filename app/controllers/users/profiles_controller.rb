class Users::ProfilesController < ApplicationController

  def show
    @user = User.find_by_username params[:username]
    if @user
      @social_links = @user.social_links
      render :show
    else
      not_found
    end
  end

end
