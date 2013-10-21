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

end
