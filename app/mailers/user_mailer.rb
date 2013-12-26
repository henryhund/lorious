class UserMailer < ActionMailer::Base
  default from: "no-reply@lorious.com"
  layout 'mail_layout'

  @@base_url = "http://" + Rails.configuration.action_mailer.default_url_options[:host]

  def invite_approved invite
    @invite = invite
    @url = @@base_url + "/users/auth/google_oauth2?invite_token=" + invite.token
    mail(to: @invite.email, subject: 'Welcome to Lorious')
  end

  def new_expert_request expert
    @expert = expert
    mail(to: @expert.email, subject: 'Expert Application Approved')
  end

  def merchant_account_approved expert
    @expert = expert
    mail(to: @expert.email, subject: 'Merchant Account Approved')
  end

  def merchant_account_declined expert, reason
    @expert, @reason = expert, reason
    mail(to: @expert.email, subject: 'Merchant Account Declined')
  end

  def test_mail
    @heading = " Appointment Completed. "
    mail(to: "pranav.dhar2@gmail.com",
         subject: "Test Mail")
  end

  def some_mail
    @head = "This is the heading"
    mail(to: @support_mail.nil? ? "support@lorious.com" : @support_mail,
         body: " has applied to be an Expert!",
         content_type: "text/html",
         subject: " has applied to be an Expert!")
  end

  def expert_applied expert
    @support_mail = Setting.find_by(name: "support_email_id").value rescue "support@lorious.com"
    mail(to: @support_mail,
         body: expert + " has applied to be an Expert!",
         content_type: "text/html",
         subject: expert + " has applied to be an Expert!")
  end

  def after_appointment_cancel appointment, reason
    @support_mail = Setting.find_by(name: "support_email_id").value rescue "support@lorious.com"
    mail(to: @support_mail,
         body: appointment.user.name + " has requested cancellation of appointment Subject: " + appointment.subject + " Dated: " +\
         appointment.created_at.to_s + "Reason: " + reason,
         content_type: "text/html",
         subject: appointment.user.name + " has requested cancellation")
  end

  def request_created_suggest_experts requests, to
     @requests, @to = requests, to
     mail(to: @to.email, subject: 'Recommended Requests')
  end

  def new_appointment_request appointment, from, to
    @appointment, @from, @to, @expert = appointment, from, to, appointment.expert
    mail(to: @to.email, subject: 'New Appointment')
  end

  def appointment_reminder appointment, to
    @appointment, @to, @appointment_with = appointment, to, appointment.appointment_with_for_user(to)
    @heading = "Upcoming Appointment!"
    mail(to: @to.email, subject: 'You have an appointment coming up in about an hour!')
  end

  def appointment_completed appointment, to
    @appointment, @to, @appointment_with = appointment, to, appointment.appointment_with_for_user(to)
    @heading = "Appointment Completed."
    mail(to: @to.email, subject: 'Appointment Completed')
  end

  def appointment_cancelled appointment, to, edited_by
    @appointment, @to, @edited_by, @appointment_with = appointment, to, edited_by, appointment.appointment_with_for_user(to)
    @heading = "Appointment Cancelled."
    mail(to: @to.email, subject: 'Appointment Cancelled')
  end

  def appointment_updated_confirm_request appointment, to, edited_by
    @appointment, @to, @edited_by, @appointment_with = appointment, to, edited_by, appointment.appointment_with_for_user(to)
    @heading = "Confirm Your Appointment."
    mail(to: @to.email, subject: 'Appointment Updated')
  end

  def appointment_confirmed_notification appointment, to
    @appointment, @to, @appointment_with = appointment, to, appointment.appointment_with_for_user(to)
    @heading = "Appointment Confirmed."
    mail(to: @to.email, subject: 'Appointment Confirmed')
  end

  def payment_successful_notification to, result
    @to, @result = to, result
    @heading = "Payment Confirmed."
    mail(to: @to.email, subject: 'Payment Confirmed')
  end
end
