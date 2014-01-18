class HomeController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :search]
  skip_before_action :profile_not_completed
  def index
  end

  def dashboard
    @expertise = Expert.order("RANDOM()").all(:limit => 4)
    @featured_experts = Expert.where(is_featured: true).limit(3).order("created_at DESC")
    @requests = Request.where("request_state != 'withdraw'").first(3)
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
          params[:tag].split(',').each do |tag|
            with(:skill_list, tag.downcase)
          end
        end
      end

      with(:location).in_radius(*Geocoder.coordinates(params[:location]), 100) if params[:location].present?

    end

    @experts = {results: @search.results, facets: AvailableTag.skills.map { |e| {:tag => e.name} } } #count: e.count -> tag frequency

    respond_to do |format|
      format.html { @experts}
      format.json { render json: @experts }
    end

  end

  def new_review
    @expert = Expert.find(params[:review][:reviewed_id])
    if params[:review][:appointment].present?
      # if appointment id has been passed associate the review with the appointment
      @appointment = Appointment.find(params[:review][:appointment])
      begin
        @review = @appointment.create_review(params.require(:review).permit(:reviewer_id, :reviewed_id, :content, :rating))
        @review.tag_list.add params[:review][:tags] if params[:review][:tags]
        @review.save validate: false
        flash[:notice] = I18n.t("review.create.success")
        redirect_to profile_path(username: @expert.username)
      rescue Exception => e
        flash[:alert] = @review.errors rescue I18n.t("review.create.failure")
        redirect_to profile_path(username: @expert.username)
      end
    else
      #Check if reviwer has any unreviewed appointments with the reviewed expert
      #This conditional is for reviews that are made from the profile page of the Expert with no association to the appointment.
      #Marks the latest appointment as reviewed
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


  end

  def update_experts
    begin
      User.find(params[:expert_ids]).each do |user|
        user.update_attributes(expert_approved: true)
      end
    rescue Exception => e
      redirect_to control_panel_url, alert: I18n.t("user.control_panel.expert.failure")
    else
      redirect_to control_panel_url, alert: I18n.t("user.control_panel.expert.success")
    end
  end

  def update_settings
    @transactions = CreditTransaction.all.order(created_at: :desc).paginate(:page => params[:page], :per_page => 15)
    begin @settings = Setting.update(params[:settings].keys, params[:settings].values)
    rescue
      redirect_to control_panel_url, alert: I18n.t("user.control_panel.settings.success")
    else
      redirect_to control_panel_url, alert: I18n.t("user.control_panel.settings.success")
    end
  end

  def update_transactions
    @settings = Setting.all
    @experts = User.where(is_expert_applied: true).where(expert_approved: [false, nil])
    begin
      @transactions = CreditTransaction.update(params[:transactions].keys, params[:transactions].values)#.paginate(:page => params[:page], :per_page => 5)
      @transactions.reject! { |p| p.errors.empty? }

      if @transactions.empty?
        redirect_to control_panel_path, alert: I18n.t("user.control_panel.transaction.success")
      else
        @transactions = WillPaginate::Collection.create(1, 5, @transactions.size) do |pager|
         pager.replace(@transactions)
        end

        render "control_panel"
      end
    rescue Exception => e
      redirect_to control_panel_path, alert: I18n.t("user.control_panel.transaction.failure")
    end

  end

  def control_panel
    admin_authentication(current_user)

    @settings = Setting.all
    @transactions = CreditTransaction.all.order(created_at: :desc).paginate(:page => params[:page], :per_page => 30)
    @experts = User.where(is_expert_applied: true).where(expert_approved: [false, nil])
  end

  def subscriptions
    @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
    render :layout => false
  end

private
  def admin_authentication(user)
    unless user.admin?
      flash[:alert] = I18n.t("user.admin.access.failure")
      redirect_to root_url
      return
    end
  end
end
