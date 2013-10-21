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
      redirect_to expert_appointment_url(id: @appointment.id), notice: I18n.t("appointment.create.success")
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  def edit
    @appointment = Appointment.find(params[:id])
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
