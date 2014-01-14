class ApptCompleted
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  
  def perform(appt_id)
    @appointment = Appointment.find(appt_id)
    @appointment.appt_state = "completed"
    @appointment.save
    UserMailer.appointment_completed(@appointment, @appointment.user).deliver
  end
end