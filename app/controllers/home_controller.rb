class HomeController < ApplicationController

  def index

  end

  def search
    if(params.has_key?(:search))
      @search = Expert.search do
        fulltext params[:search] do
          boost_fields :first_name => 5.0
        end
        paginate(:per_page => 15, :page => params[:page])
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
