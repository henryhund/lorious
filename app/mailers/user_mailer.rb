class UserMailer < ActionMailer::Base
  default from: "testing@devbrother.com"

  @@base_url = "http://" + Rails.configuration.action_mailer.default_url_options[:host]

  def invite_approved invite
    @invite = invite
    @url = @@base_url + "/users/auth/google_oauth2?invite_token=" + invite.token
    mail(to: @invite.email, subject: 'Welcome to Lorious')
  end

  def new_expert_request
    
  end
  
  def test_mail
    mail(to: "pranav.dhar2@gmail.com",
         body: "email_body",
         content_type: "text/html",
         subject: "Test Scheduled Task!!")
  end
  
  def request_created_suggest_experts request, to
     @request, @to = request, to
     mail(to: @to, subject: 'Recommended Request')
  end
  
  def new_appointment_request appointment, from, to
    @appointment, @from, @to, @expert = appointment, from, to, appointment.expert
    mail(to: @to.email, subject: 'New Appointment')
  end
  
  def appointment_reminder appointment, to
    @appointment, @to, @appointment_with = appointment, to, appointment.appointment_with_for_user(to)
    mail(to: @to.email, subject: 'Appointment Reminder')  
  end
  
  def appointment_completed appointment, to
    @appointment, @to, @appointment_with = appointment, to, appointment.appointment_with_for_user(to)
    mail(to: @to.email, subject: 'Appointment Completed')  
  end
  
  def appointment_updated_confirm_request appointment, to, edited_by
    @appointment, @to, @edited_by, @expert = appointment, to, edited_by, appointment.expert
    mail(to: @to.email, subject: 'Appointment Updated')
  end

  def appointment_confirmed_notification appointment, to
    @appointment, @to, @appointment_with = appointment, to, appointment.appointment_with_for_user(to)
    mail(to: @to.email, subject: 'Appointment Confirmed')
  end
end
