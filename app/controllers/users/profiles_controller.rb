class Users::ProfilesController < ApplicationController

  def show
    @user = User.find_by_username params[:username]
    if @user
      @social_links = @user.social_links
      @interests = @user.interests
      @expertise = @user.expertise if @user.expert?
      @reviews = @user.reviews_received.includes(:reviewer, :tags)
      render :show
    else
      not_found
    end
  end

end
