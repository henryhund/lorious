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
end
