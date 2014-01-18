class Experts::AvailabilitiesController < ApplicationController

  layout false

  def edit
    @availability = current_user.availability || current_user.create_availability #todo change this when admin panel is done
    @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
  end

  def update
    begin
      availability = Availability.find params[:id]
      availability.attributes = availability_params
      availability.timezone_in_minutes = availability.get_time_zone_difference_in_minutes_from_gmt
      availability.save
      current_user.set_availability JSON.parse(params[:availability][:timespans]), availability.timezone_in_minutes
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("availability.update.failure")
    else
      redirect_to users_url, notice: I18n.t("availability.update.success")
    end
  end

  private

  def availability_params
    params.require(:availability).permit(:hourly_cost, :time_zone, :timezone_in_minutes)
  end


end
