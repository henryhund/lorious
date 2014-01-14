class Users::AppointmentsController < ApplicationController

  layout false

  def index
    
  end

  def pending
    @appointments = Appointment.pending.where("user_id = ? OR expert_id = ?", current_user.id, current_user.id).order(:created_at => :desc)
  end

  def upcoming
    @appointments = Appointment.upcoming.where("user_id = ? OR expert_id = ?", current_user.id, current_user.id).order(:created_at => :desc)
  end

  def history
    @appointments = Appointment.history.where("user_id = ? OR expert_id = ?", current_user.id, current_user.id).order(:created_at => :desc)
  end

end
