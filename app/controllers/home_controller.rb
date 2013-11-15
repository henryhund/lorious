class HomeController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  def index

  end

  def dashboard
    
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
    #Check if reviwer has any unreviewed appointments with the reviewed expert
    if @expert.is_unreviewed_appointments(params[:review][:reviewer_id])
      begin
        @review = Review.new params.require(:review).permit(:reviewer_id, :reviewed_id, :content, :rating)
        @review.save
      rescue Exception => e
        flash[:alert] = @review.errors rescue I18n.t("review.create.failure") 
        redirect_to profile_path(username: @expert.username)
      else
        @review.tag_list.add params[:review][:tags] if params[:review][:tags]
        @review.save validate: false
        @expert.mark_appointment_reviewed(params[:review][:reviewer_id])
        flash[:notice] = I18n.t("review.create.success")  
        redirect_to profile_path(username: @expert.username)
      end
    else
      flash[:notice] = I18n.t("review.create.error") 
      redirect_to profile_path(username: @expert.username)      
    end
    
  end
  
  def update_experts
    begin
      User.find(params[:expert_ids]).each do |user|
        user.update_attributes(expert_approved: true)
      end
    rescue Exception => e
      debugger
      redirect_to control_panel_url, alert: "Error approving experts"
    else
      redirect_to control_panel_url, alert: "Successfully approved experts"
    end
  end
  
  def update_settings
    @transactions = CreditTransaction.all.order(created_at: :desc).paginate(:page => params[:page], :per_page => 15)
    begin @settings = Setting.update(params[:settings].keys, params[:settings].values)
    rescue
      redirect_to control_panel_url, alert: "Error updating settings"
    else
      redirect_to control_panel_url, alert: "Successfully updated settings"
    end
  end
  
  def update_transactions
    #CreditTransaction.update(params[:transactions].keys, params[:transactions].values)
    @settings = Setting.all
    
    begin
      @transactions = CreditTransaction.update(params[:transactions].keys, params[:transactions].values)#.paginate(:page => params[:page], :per_page => 5)
      @transactions.reject! { |p| p.errors.empty? }
      
      if @transactions.empty?
        redirect_to control_panel_path, alert: "Successfully updated transactions"
      else
        @transactions = WillPaginate::Collection.create(1, 5, @transactions.size) do |pager|
         pager.replace(@transactions)
        end
        
        render "control_panel"
      end
    rescue Exception => e
      redirect_to control_panel_path, alert: "Error updating transactions"
    end
    
  end  
  
  def control_panel
    admin_authentication(current_user)
    
    @settings = Setting.all
    @transactions = CreditTransaction.all.order(created_at: :desc).paginate(:page => params[:page], :per_page => 15)
  end
  
  def subscriptions
    render :layout => false
  end
  
private
  def admin_authentication(user)
    unless user.admin?
      flash[:alert] = "You do not have access to this page."
      redirect_to root_url 
      return 
    end
  end
end
