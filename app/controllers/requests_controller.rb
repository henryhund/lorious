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
    @request = Request.new(params.require(:request).permit(:is_local, :is_online, :company_description, :problem_description, :local_zip, :appt_length, :other_problem_type, :requester_id, :company_name, :company_url, :skill_list, :problem_ids => []))
    
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
  
  def show
    @request = Request.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service }
    end
  end
  
end