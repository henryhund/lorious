class Experts::ExpertiseController < ApplicationController

  layout false

  def new
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

  private

  def expertise_params
    params.require(:expertise).permit(:title, :description)
  end

end
