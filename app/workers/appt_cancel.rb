class ApptCancel
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  
  def perform(appt_id)
    @appointment = Appointment.find(appt_id)
    if @appointment.appt_state == "new"
      @appointment.appt_state = "cancelled"
      @appointment.save
      #Auto Cancel
      UserMailer.auto_cancel_appointment(@appointment, @appointment.user).deliver
      UserMailer.auto_cancel_appointment(@appointment, @appointment.expert).deliver
    end
  end
end