class ReviewsController < ApplicationController
  before_filter :authenticate_user!
  def new
    @expert_id = params[:expert_id]
    @expert = Expert.find(params[:expert_id])
    
    @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
    if params[:appointment].present?
      @appointment = Appointment.find(params[:appointment])  
    end
  end
  
  def request_cancel
    
    if params[:appointment].present?
      @appointment = Appointment.find(params[:appointment])  
      @transaction = @appointment.credit_transaction
      @transaction.is_request_cancel = true
      @transaction.request_cancel_reason = params[:request_cancel_reason]
      @transaction.save validate: false
  
      flash[:notice] = "Cancellation request submitted."
      redirect_to users_url
    end
  end
  
end