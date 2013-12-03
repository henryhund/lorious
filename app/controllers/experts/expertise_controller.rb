class Experts::ExpertiseController < ApplicationController

  layout false

  def new
    @existing_expertise = current_user.expertise  
    @expertise = current_user.expertise.new
  end

  def create
    begin
      current_user.expertise.create expertise_params
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("expertise.create.failure")
    else
      redirect_to users_url, notice: I18n.t("expertise.create.success")
    end
  end

  def destroy
    begin
      @expertise = Expertise.find(params[:id])
      @expertise.destroy
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("expertise.destroy.failure")
    else
      redirect_to users_url, notice: I18n.t("expertise.destroy.success")
    end
  end
  
  private

  def expertise_params
    params.require(:expertise).permit(:title, :description)
  end

end
