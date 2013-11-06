class ReviewsController < ApplicationController
  before_filter :authenticate_user!
  def new
    @expert_id = params[:expert_id]
    @available_skills = AvailableTag.skills.map { |e| [e.name, e.name] }
  end
end