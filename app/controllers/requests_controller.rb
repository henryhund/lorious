class RequestsController < ApplicationController
  
  def new 
    @request = Request.new
    respond_to do |format|
      format.html { @request}
      format.json { render json: @request }
    end
  end
  
  def create
    @request = Request.new(params.require(:request).permit(:other_problem_type, :company_name, :company_url, :skill_list, :problem_ids => []))
    
    respond_to do |format|
      if @request.save
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