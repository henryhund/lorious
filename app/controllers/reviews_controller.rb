class ReviewsController < ApplicationController
  before_filter :authenticate_user!
  def new
    @expert_id = params[:expert_id]
    @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
    if params[:appointment].present?
      @appointment = Appointment.find(params[:appointment])  
    end
    
  end
end