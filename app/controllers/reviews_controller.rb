class ReviewsController < ApplicationController
  before_filter :authenticate_user!
  def new
    
    @expert_id = params[:expert_id]
    @expert = Expert.find(params[:expert_id])
    
    @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
    if params[:appointment].present?
      @appointment = Appointment.find(params[:appointment])  
      if @appointment.review.present?
        flash[:alert] = I18n.t("review.created.failure") 
        return redirect_to users_url(anchor: 'appointment')
      end
    end
  end
  
  def edit
    @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
    @review = Review.find(params[:id])
    @rating_score = @review.rating
  end
  
  def update_review
    @review = Review.find(params[:id])
    if @review.update_attributes(params.require(:review).permit(:content, :rating))
      @review.tag_list = []
      @review.tag_list.add params[:review][:tags] if params[:review][:tags]
      @review.save validate: false
      redirect_to users_url(anchor: 'appointment'), notice: I18n.t("review.update.success")
    else
      redirect_to users_url, notice: I18n.t("review.update.failure")  
    end
  end
  def request_cancel
    
    if params[:appointment].present?
      @appointment = Appointment.find(params[:appointment])  
      @transaction = @appointment.credit_transaction
      @transaction.is_request_cancel = true
      @transaction.request_cancel_reason = params[:request_cancel_reason]
      @transaction.save validate: false
  
      UserMailer.delay.after_appointment_cancel(@appointment, @transaction.request_cancel_reason)
      flash[:notice] = I18n.t("review.cancel.success")  
      redirect_to users_url
    end
  end
  
end