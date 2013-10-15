class RequestsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  
  def new 
    @request = Request.new
    respond_to do |format|
      format.html { @request}
      format.json { render json: @request }
    end
  end
  
  def create
    @request = Request.new(params.require(:request).permit(:problem_headline, :is_local, :is_online, :company_description, :problem_description, :local_zip, :appt_length, :other_problem_type, :requester_id, :company_name, :company_url, :skill_list, :problem_ids => []))
    
    respond_to do |format|
      if @request.save
        if params[:request][:other_problem_type].present?
          @request.create_problem_type(params[:request][:other_problem_type])
        end
        
        format.html { redirect_to root_url, notice: 'Request was successfully created.' }
        format.json { render json: @request, status: :created, location: @request }
      else
        format.html { render action: "new" }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def latest
    
    @request = Request.search do
      paginate(:per_page => 15, :page => params[:page])
      facet :skill_list
      
      if params[:problems].present?
        all_of do
          params[:problems].split(',').each do |problem|
            with(:problems, problem.downcase)
          end
        end
      end
      
      if params[:tags].present?
        all_of do
          params[:tags].split(',').each do |tag|
            with(:skill_list, tag)
          end
        end
      end
      
    end
    
    @requests = {results: @request.results, problems: Request.get_unique_problem_types, tags: @request.facet(:skill_list).rows.map {  |e| e.value }  } 
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @requests }
    end
  end
  
end