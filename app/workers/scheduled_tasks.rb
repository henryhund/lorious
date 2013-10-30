class ScheduledTask
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }

  def perform
    
    #UserMailer.test_mail.deliver
  end
end