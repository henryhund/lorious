class AppointmentsController < ApplicationController

  before_filter :get_expert
  before_filter :form_data, only: [:new, :edit]

  def new
    @appointment = @expert.appointments.new
  end

  def create
    begin
      @appointment = @expert.appointments.build appointment_params
      @appointment.user_id = current_user.id
      @appointment.save
    rescue Exception => e
      redirect_to new_expert_appointment_url, notice: I18n.t("appointment.create.failure")
    else
      UserMailer.delay.new_appointment_request_to_expert(@appointment)
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

  def confirm
    @appointment = Appointment.find(params[:id])
    if current_user.expert?
      @appointment.expert_confirmed = true
    else
      @appointment.user_confirmed = true
    end
    @appointment.save
    if @appointment.confirmed?
      UserMailer.delay.appointment_confirmed_notification(@appointment, @appointment.user)
      UserMailer.delay.appointment_confirmed_notification(@appointment, @appointment.expert)
    end
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
    @default_duration = 30
    @hourly_rate_in_credit = @expert.hourly_rate_in_credit
  end

end
