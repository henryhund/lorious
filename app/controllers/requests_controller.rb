class RequestsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  
  def new 
    
    #temp
    #@event = {
    #  'summary' => 'this is a summary',
    #  'location' => 'this is where the location goes',
    #   'description' => 'desc',
    #  'start' => {
    #    'dateTime' => '2013-11-07T13:00:00.000-00:00' # Date with :- offset so (yyyy-mm-dd T hh:mm:ss.000-offset)
    #  },
    #  'end' => {
    #    'dateTime' => '2013-11-07T13:25:00.000-00:00' # Date with :- offset so (yyyy-mm-dd T hh:mm:ss.000-offset)
    #  },
    #  'organizer' => {
    #    'email' => 'pranav@codebrahma.com'
    #  },
    #  'attendees' => [
    #    {
    #      'email' => 'pranav.dhar2@gmail.com'
    #    },
    #    {
    #      'email' => 'pranav@codebrahma.com'
    #    }
    #  ]
    #}
    
    # Create event using the json structure 
    
    #result = $g_client.execute(:api_method => $g_service.events.insert,
    #                      :parameters => {'calendarId' => 'primary'},
    #                      :body => JSON.dump(@event),
    #                      :headers => {'Content-Type' => 'application/json'})
    
    #debugger
    #end temp
    @request = Request.new
    @request.appt_length = 30
    @header = "Create Request"
    respond_to do |format|
      format.html { @request}
      format.json { render json: @request }
    end
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
        format.html { redirect_to @request, notice: 'Request was successfully withdrawn.' }
        format.json { head :no_content }
      else
        format.html { redirect_to root, notice: 'Error withdrawing request!' }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
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
  
  def update
    @request = Request.find(params[:id])
    
    respond_to do |format|
      if @request.update_attributes(params.require(:request).permit(:request_state, :problem_headline, :is_local, :is_online, :company_description, :problem_description, :local_zip, :appt_length, :other_problem_type, :requester_id, :company_name, :company_url, :skill_list, :problem_ids => []))
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
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