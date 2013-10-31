class AppointmentsController < ApplicationController

  before_filter :get_expert
  before_filter :form_data, only: [:new, :edit]

  def new
    @appointment = @expert.appointments.new
  end

  def create
    begin
      @appointment = @expert.appointments.build appointment_params
      @appointment.user_id = get_user.id
      @appointment.request_id = params[:appointment][:request_id]
      confirm_appointment_for_current_user
      @appointment.save
    rescue Exception => e
      redirect_to new_expert_appointment_url, notice: I18n.t("appointment.create.failure")
    else
      UserMailer.delay.new_appointment_request(@appointment, current_user, @appointment.appointment_with_for_user(current_user))
      redirect_to expert_appointment_url(id: @appointment.id), notice: I18n.t("appointment.create.success")
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  def edit
    @appointment = Appointment.find(params[:id])
  end

  def update
    @appointment = Appointment.find(params[:id])
    begin
      @appointment.attributes = appointment_params
      if current_user.expert?
        @appointment.user_confirmed = false
      else
        @appointment.expert_confirmed = false
      end
      @appointment.save
    rescue Exception => e
      redirect_to expert_appointment_url(@appointment.expert.id, @appointment.id), notice: I18n.t("appointment.update.failure")
    else
      UserMailer.delay.appointment_updated_confirm_request(@appointment, @appointment.appointment_with_for_user(current_user), current_user)
      redirect_to expert_appointment_url(@appointment.expert.id, @appointment.id), notice: I18n.t("appointment.update.success")
    end
  end
  
  def cancel
    begin
      @appointment = Appointment.find params[:id]
      @appointment.appt_state = "cancelled"
      @appointment.save
      
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("appointment.cancel.failure")
    else
      # remove any previous worker instances 
      @appointment.sidekiqjobs.each do |s|
        Sidekiq::Status.cancel s.sidekiq_id  
      end
      redirect_to users_url, notice: I18n.t("appointment.cancel.success")
    end
  end
  
  def confirm
    @appointment = Appointment.find(params[:id])
    if current_user.expert?
      @appointment.expert_confirmed = true
    else
      @appointment.user_confirmed = true
    end
    
    if @appointment.confirmed?
      @appointment.appt_state = "confirmed"
      UserMailer.delay.appointment_confirmed_notification(@appointment, @appointment.user)
      UserMailer.delay.appointment_confirmed_notification(@appointment, @appointment.expert)
    end
    
    @appointment.save
    # remove any previous worker instances 
    @appointment.sidekiqjobs.each do |s|
      Sidekiq::Status.cancel s.sidekiq_id  
    end
    @appointment.sidekiqjobs.clear
    #create a reminder worker task and a appointment completed task
    if @appointment.time - Time.now < 3600
      @appointment.sidekiqjobs.create(sidekiq_id: ApptReminder.perform_at(@appointment.time, @appointment.id))
    else
      @appointment.sidekiqjobs.create(sidekiq_id: ApptReminder.perform_at(@appointment.time - 1.hours, @appointment.id))
    end
    
    @appointment.sidekiqjobs.create(sidekiq_id: ApptCompleted.perform_at(@appointment.time + @appointment.duration.minutes, @appointment.id))
    redirect_to expert_appointment_url(current_user.id, @appointment.id), notice: I18n.t("appointment.confirmed")
  end

  private

  def get_expert
    @expert = Expert.find_by_id(params[:expert_id])
  end

  def appointment_params
    params.require(:appointment).permit(:time, :duration, :place, :subject, :description, :online)
  end

  def form_data
    @duration_options = (30..360).step(30).map { |d| [ d < 60 ? "#{d.to_s} minutes" : "#{(d/60.round(1)).to_s} #{"hour".pluralize(d/60.round(1))}" , d.to_s ] }
    @default_duration = params[:duration].to_i || 30
    @hourly_rate_in_credit = @expert.hourly_rate_in_credit
    @user_id = params[:user_id]
    @request_id = params[:request_id]
  end

  def get_user
    if current_user.expert?
      User.find_by_id(params[:appointment][:user_id])
    else
      current_user
    end
  end

  def confirm_appointment_for_current_user
    if current_user.expert?
      @appointment.expert_confirmed = true
    else
      @appointment.user_confirmed = true
    end
  end

end
