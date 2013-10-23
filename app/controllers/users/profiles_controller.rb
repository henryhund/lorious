class Users::ProfilesController < ApplicationController

  def show
    @user = User.find_by_username params[:username]
    if @user
      @social_links = @user.social_links
      @interests = @user.interests
      if @user.expert?
        @expertise = @user.expertise
        @availability = @user.availability
      end
      @reviews = @user.reviews_received.includes(:reviewer, :tags)
      
      @available_skills = AvailableTag.skills.map { |e| [e.name, e.name] }
      
      render :show
    else
      not_found
    end
  end

end
