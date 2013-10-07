class HomeController < ApplicationController

  def index

  end

  def search
    
    if(params.has_key?(:keyword))
      @search = Expert.search do
        fulltext params[:keyword] do
          boost_fields :first_name => 5.0
        end
        facet :skill_list
        paginate(:per_page => 15, :page => params[:page])
        
        if params[:tag].present?
          all_of do
            #params[:tag].each do |tag|
              with(:skill_list, params[:tag])
            #end
          end
        end
        
        with(:location).in_radius(*Geocoder.coordinates(params[:location]), 100) if params[:location].present?
    
      end
      @experts = @search.results
    else
      @experts = Expert.all.paginate(:per_page => 15, :page => params[:page])    
    end
    
    respond_to do |format|
      format.html { @experts}
      format.json { render json: @experts }
    end
    
  end
end
