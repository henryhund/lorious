class HomeController < ApplicationController

  def index

  end

  def search
    
    @search = Expert.search do
      
      if params[:keyword].present?
        keywords params[:keyword] do
          boost_fields :first_name => 5.0
        end  
      end
      
      facet :skill_list
      paginate(:per_page => 15, :page => params[:page])
      
      if params[:tag].present?
        all_of do
          #params[:tag].each do |tag|
          #  with(:skill_list, tag)
          #end
          params[:tag].split(',').each do |tag|
            with(:skill_list, tag)
          end
        end
      end
      
      with(:location).in_radius(*Geocoder.coordinates(params[:location]), 100) if params[:location].present?
  
    end
    @experts = {results: @search.results, facets: @search.facet(:skill_list).rows.map {  |e| {tag: e.value} } } #count: e.count -> tag frequency
    
    respond_to do |format|
      format.html { @experts}
      format.json { render json: @experts }
    end
    
  end
  
  def new_review
    @expert = Expert.find(params[:review][:reviewed_id])
    begin
      @review = Review.new params.require(:review).permit(:reviewer_id, :reviewed_id, :content, :rating)
      @review.save
    rescue Exception => e
      flash[:alert] = @review.errors rescue "Error saving Review"
      redirect_to profile_path(username: @expert.username)
    else
      @review.tag_list.add params[:review][:tags] if params[:review][:tags]
      @review.save validate: false
      flash[:notice] = "Your review has been succesfully added."
      redirect_to profile_path(username: @expert.username)
    end
  end
  
  def subscriptions
    render :layout => false
  end
end
