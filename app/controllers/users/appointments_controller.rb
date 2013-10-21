class Users::AppointmentsController < ApplicationController

  layout false

  def index
    
  end

  def pending
    @appointments = current_user.appointments.pending.includes([:expert, :user])
  end

  def upcoming
    @appointments = current_user.appointments.upcoming.includes([:expert, :user])
  end

  def history
    @appointments = current_user.appointments.history.includes([:expert, :user])
  end

  def confirm
    @appointment = Appointment.find(params[:id])
    @appointment.confirmed = true
    @appointment.save
    redirect_to users_url, notice: I18n.t("appointment.confirmed")
  end

end
