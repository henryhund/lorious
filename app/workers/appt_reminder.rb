class ApptReminder
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  
  def perform(appt_id)
    appointment = Appointment.find(appt_id)
    UserMailer.test_mail.deliver
  end
end