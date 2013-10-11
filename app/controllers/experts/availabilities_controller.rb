class Experts::AvailabilitiesController < ApplicationController

  layout false

  def edit
    @availability = current_user.availability || current_user.create_availability #todo change this when admin panel is done
  end

  def update
    begin
      availability = Availability.find params[:id]
      availability.update_attributes(availability_params)
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("availability.update.failure")
    else
      redirect_to users_url, notice: I18n.t("availability.update.success")
    end
  end

  private

  def availability_params
    params.require(:availability).permit(:hourly_cost)
  end

end
