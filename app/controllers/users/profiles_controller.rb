class Users::ProfilesController < ApplicationController
  skip_before_action :profile_not_completed
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
      
      @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
      
      render :show
    else
      not_found
    end
  end

end
