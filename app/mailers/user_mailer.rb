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

  def new_appointment_request_to_expert appointment
    @appointment, @expert, @user = appointment, appointment.expert, appointment.user
    mail(to: @expert.email, subject: 'New Appointment')
  end
end
