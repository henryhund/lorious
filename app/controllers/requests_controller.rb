class RequestsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  
  def new 
    @request = Request.new
    @request.appt_length = 30
    @header = "Create Request"
    respond_to do |format|
      format.html { @request}
      format.json { render json: @request }
    end
    @available_problems = AvailableTag.problems.map { |e| [e.name, e.name] }
    @available_skills = AvailableTag.skills.map { |e| [e.name, e.name] }
  end
  
  def show
    @request = Request.find(params[:id])
  end

  def edit
    @header = "Edit Request"
    @request = Request.find(params[:id])
  end
  
  def withdraw_request
    @request = Request.find(params[:id])
    respond_to do |format|
      if @request.update_attributes(:request_state => "withdraw")
        format.html { redirect_to @request, notice: I18n.t("request.withdraw.success") }
        format.json { head :no_content }
      else
        format.html { redirect_to root, notice: I18n.t("request.withdraw.failure") }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def create
    @request = Request.new(params.require(:request).permit(:problem_headline, :is_local, :is_online, :company_description, :problem_description, :local_zip, :appt_length, :other_problem_type, :requester_id, :company_name, :company_url, :skill_list, :problem_list))
    
    respond_to do |format|
      if @request.save
        @request.skill_list.add params[:request][:skill_list] if params[:request][:skill_list]
        @request.problem_list.add params[:request][:problem_list] if params[:request][:problem_list]
        @request.save validate: false
        
        format.html { redirect_to root_url, notice: I18n.t("request.create.success") }
        format.json { render json: @request, status: :created, location: @request }
      else
        format.html { render action: "new" }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @request = Request.find(params[:id])
    
    respond_to do |format|
      if @request.update_attributes(params.require(:request).permit(:request_state, :problem_headline, :is_local, :is_online, :company_description, :problem_description, :local_zip, :appt_length, :other_problem_type, :requester_id, :company_name, :company_url, :skill_list, :problem_list))
        format.html { redirect_to @request, notice: I18n.t("request.update.success") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
      order_by :created_at, :desc
    end
    
    @requests = {results: @request.results, problems: Request.get_unique_problem_types, tags: @request.facet(:skill_list).rows.map {  |e| e.value }  } 
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @requests }
    end
  end
  
end