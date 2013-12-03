class Users::InterestsController < ApplicationController

  layout false

  def new
    @existing_interests = current_user.interests      
    @interest = current_user.interests.new
  end

  def create
    begin
      current_user.interests.create interests_params
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("interests.create.failure")
    else
      redirect_to users_url, notice: I18n.t("interests.create.success")
    end
  end

  def destroy
    begin
      @interest = Interest.find(params[:id])
      @interest.destroy
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("interests.destroy.failure")
    else
      redirect_to users_url, notice: I18n.t("interests.destroy.success")
    end
  end
  private

  def interests_params
    params.require(:interest).permit(:title, :description)
  end

end
