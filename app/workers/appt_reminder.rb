class ApptReminder
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  
  def perform(appt_id)
    @appointment = Appointment.find(appt_id)
    UserMailer.appointment_reminder(@appointment, @appointment.user ).deliver
    UserMailer.appointment_reminder(@appointment, @appointment.expert ).deliver
  end
end