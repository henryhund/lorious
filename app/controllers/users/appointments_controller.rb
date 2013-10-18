class Users::AppointmentsController < ApplicationController

  layout false

  def index
    
  end

  def pending
    @pending_appointments = current_user.appointments.pending.includes([:expert, :user])
  end

end
