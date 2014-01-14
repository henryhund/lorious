class Users::SocialMediaController < ApplicationController

  layout false

  def index
    @social_media = current_user.social_media
    @social_links = current_user.social_links
  end

  def new
    @social_media = SocialMedium.new
    @available_media = SocialMedium.available_media.map {|k, v| [k, k] }
  end

  def create
    oauth_provider = SocialMedium.available_media[params[:social_medium][:name]]
    redirect_to "/users/auth/#{oauth_provider}"
  end

  def destroy
    @social_medium = SocialMedium.find params[:id]
    @social_medium.destroy
    render text: "done"
  end

end
