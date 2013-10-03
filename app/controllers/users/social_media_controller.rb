class Users::SocialMediaController < ApplicationController

  layout false

  def index
    
  end

  def new
    @social_media = SocialMedium.new
    @available_media = SocialMedium.available_media.map {|k, v| [k, k] }
  end

  def create
    oauth_provider = SocialMedium.available_media[params[:social_medium][:name]]
    redirect_to "/users/auth/#{oauth_provider}"
  end

end
