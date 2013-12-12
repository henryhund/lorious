class AppointmentsController < ApplicationController
  before_filter :authenticate_user!, except: [:new_hangout]
  around_filter :time_zone, only: [:create, :update]
  
  before_filter :get_expert
  before_filter :form_data, only: [:new, :edit]
  
  skip_before_action :verify_authenticity_token, only: [:new_hangout]
  
  def new
    
    if current_user.expert?
      unless (params[:expert_id].to_i == current_user.id) 
        unless current_user.braintree_id.present? && current_user.braintree_token.present?
          flash[:alert] = "Cannot create appointment, need to have credit card on file"
          return redirect_to users_url(anchor: "credit")
        end   
      else
        unless current_user.braintree_merchant_id.present? && ( current_user.braintree_merchant_status.present? && current_user.braintree_merchant_status == "active")
          flash[:alert] = "Cannot create appointment, need to have and active merchant account on file"
          return redirect_to users_url(anchor: "credit") 
        end   
      end
    else
      unless current_user.braintree_id.present? && current_user.braintree_token.present?
        flash[:alert] = "Cannot create appointment, need to have credit card on file"
        return redirect_to users_url(anchor: "credit")  
      end
    end
    
  end

  def create
    begin
      @appointment = @expert.appointments.build appointment_params
      @appointment.user_id = get_user.id
      @appointment.request_id = params[:appointment][:request_id]
      @appointment.description = params[:appointment][:what_message]
      confirm_appointment_for_current_user
      @appointment.check_valid = true
      
      if @appointment.save
        UserMailer.delay.new_appointment_request(@appointment, current_user, @mail_to)
        if params[:appointment][:what_message].present?
          #Create a new appoinment conversation
          if current_user.expert?
            @message_receiver = @appointment.expert
          else
            @message_receiver = @appointment.user  
          end
          
          @receipt = current_user.send_message(@message_receiver, params[:appointment][:what_message], @appointment.subject, true, nil)
          @appointment.message_id = @receipt.conversation.id
          @appointment.save validate: false
          
        end
        
        @appointment.skill_list.add params[:appointment][:skill_list] if params[:appointment][:skill_list]
        @appointment.save validate: false

        redirect_to expert_appointment_url(id: @appointment.id), notice: I18n.t("appointment.create.success"), error: @appointment.errors
      else
        get_expert
        persist_data
        flash[:alert] = @appointment.errors.full_messages.to_sentence
        render action: "new"
      end
    rescue Exception => e
      redirect_to new_expert_appointment_url(params[:appointment]), notice: I18n.t("appointment.create.failure")
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    
    if @appointment.message_id.present?
      @conversation = Conversation.find_by_id(@appointment.message_id)
      current_user.mark_as_read(@conversation)  
    end
    
    if current_user.expert?
      unless @appointment.expert.id == current_user.id
        @message_to = @appointment.expert
      else
        @message_to = @appointment.user  
      end
    else
      @message_to = @appointment.expert
    end

    respond_to do |format|
      format.js { render "show.js" }      
      format.html { render "show" }
    end

  end

  def edit
    @appointment = Appointment.find(params[:id])
    @edit = true
    @hours_edit = Setting.find_by(name: "hours_edit_allowed").value rescue "8"
    if (@appointment.appt_state != "new") && (@appointment.time.in_time_zone(@appointment.time_zone) - @hours_edit.to_i.hours) < Time.now
      flash[:alert] = "Cannot edit appointment " + @hours_edit + " hours before scheduled time."
      return redirect_to users_url(anchor: "appointment")  
    end
    
    @appointment.time = @appointment.time.in_time_zone(@appointment.time_zone).to_formatted_s(:long)
  
  end

  def update
    @appointment = Appointment.find(params[:id])
    begin
      @appointment.attributes = appointment_params
      if current_user.expert?
        unless @appointment.expert.id == current_user.id
          @appointment.expert_confirmed = false
          @appointment.user_confirmed = true
          @mail_to = @appointment.expert
        else
          @appointment.expert_confirmed = true
          @appointment.user_confirmed = false
          @mail_to = @appointment.user  
        end
      else
        @appointment.expert_confirmed = false
        @appointment.user_confirmed = true
        @mail_to = @appointment.expert
      end
      @appointment.appt_state = "new"
      @appointment.check_valid = true
      if @appointment.save
        #updating tags
        @appointment.skill_list = []
        @appointment.skill_list.add params[:appointment][:skill_list]
        @appointment.save validate: false
      end
      raise @appointment.errors.full_messages.join.to_s if !@appointment.valid?
      
    rescue Exception => e
      redirect_to expert_appointment_url(@appointment.expert.id, @appointment.id), notice: I18n.t("appointment.update.failure"), alert: e.message
    else
      UserMailer.delay.appointment_updated_confirm_request(@appointment, @mail_to, current_user)
      redirect_to expert_appointment_url(@appointment.expert.id, @appointment.id), notice: I18n.t("appointment.update.success")
    end
  end
  
  def cancel
    begin
      @appointment = Appointment.find params[:id]
      @hours_cancellation = Setting.find_by(name: "hours_cancellation_allowed").value rescue "8"
      
      if (@appointment.appt_state != "new") && (@appointment.time.in_time_zone(@appointment.time_zone) - @hours_cancellation.to_i.hours) < Time.now
        flash[:alert] = "Cannot cancel appointment " + @hours_cancellation + " hours before scheduled time."
        return redirect_to users_url(anchor: "appointment")  
      end
      
      if @appointment.appt_state == "confirmed"
        @appointment.credit_transaction.state_change = "refund"
        @appointment.credit_transaction.save
        
        @appointment.sidekiqjobs.each do |s|
          Sidekiq::Status.cancel s.sidekiq_id  
        end
        
        unless @appointment.credit_transaction.valid?
          flash[:alert] = @appointment.credit_transaction.errors.full_messages.join
        end
      end
      
      @appointment.appt_state = "cancelled"
      @appointment.save
      
      UserMailer.delay.appointment_cancelled(@appointment, @appointment.user, current_user)
      UserMailer.delay.appointment_cancelled(@appointment, @appointment.expert, current_user)
      
      redirect_to users_url, notice: I18n.t("appointment.cancel.success")
    rescue Exception => e
      redirect_to users_url, notice: I18n.t("appointment.cancel.failure")
    end
  end
  
  def confirm
    
    #if current user doesn't have an account then flash message and redirect 
    @appointment = Appointment.find(params[:id])
    if current_user.id == @appointment.expert.id
      if current_user.braintree_merchant_id.present? && ( current_user.braintree_merchant_status.present? && current_user.braintree_merchant_status == "active")
        @appointment.expert_confirmed = true
      else
        flash[:alert] = "Cannot confirm appointment, need to have and active merchant account on file"
        return redirect_to users_url(anchor: "credit") 
      end
    elsif current_user.id == @appointment.user.id
      if current_user.braintree_id.present? && current_user.braintree_token.present?
        @appointment.user_confirmed = true
      else
        flash[:alert] = "Cannot confirm appointment, need to have credit card on file"
        return redirect_to users_url(anchor: "credit")  
      end
    end
    
    if @appointment.confirmed?
      #Create Payment in Escrow and send out email to user
      @appointment.appt_state = "confirmed"
      
      unless @appointment.credit_transaction.present?
        debugger
        # Calculate payment brackets
        @transaction_amount = @appointment.total_credit_cost.to_f
        @slot_1_limit= Setting.find_by(name: "slot_1_limit").value.to_f rescue 10.0
        @slot_2_limit= Setting.find_by(name: "slot_2_limit").value.to_f rescue 20.0
        @slot_3_limit= Setting.find_by(name: "slot_3_limit").value.to_f rescue 30.0
        
        if @transaction_amount > Setting.find_by(name: "minimum_transaction_amount").value.to_f && @transaction_amount <= @slot_1_limit
          @pay_amount = ( (Setting.find_by(name: "slot_1_percent").value rescue 30.0).to_f * @transaction_amount / 100)
        elsif @transaction_amount > @slot_1_limit && @transaction_amount <= @slot_2_limit
          @pay_amount = ( (Setting.find_by(name: "slot_2_percent").value rescue 20.0).to_f * @transaction_amount / 100)
        elsif @transaction_amount > @slot_3_limit
          @pay_amount = ( (Setting.find_by(name: "slot_3_percent").value rescue 10.0).to_f * @transaction_amount / 100)
        end
        
        @result = Braintree::Transaction.sale(
          :amount => @appointment.total_credit_cost,
          :merchant_account_id => @appointment.expert.braintree_merchant_id,
          :customer_id => @appointment.user.braintree_id,
          :payment_method_token => @appointment.user.braintree_token,
          :options => {
            :submit_for_settlement => true,
            :hold_in_escrow => true
          },
          :service_fee_amount => @pay_amount.to_s
        )
        
        if @result.success?
          #send payment confirmation message
          
          @appointment.create_credit_transaction(
            :amount => @result.transaction.amount,
            :added => true,
            :transacted_id => @appointment.expert.id,
            :transacter_id => @appointment.user.id,
            :transaction_id => @result.transaction.id,
            :description => "Transaction ID: " + @result.transaction.id + " Amount Charged: $" + @result.transaction.amount.to_s,
            :transaction_status => @result.transaction.status,
            :transaction_escrow_status => @result.transaction.escrow_status
          )
          
          UserMailer.delay.payment_successful_notification(@appointment.user, @appointment.credit_transaction)
        else
          @error_string = ""
          @trasact_errors = @result.errors.map { |a| a.message} 
          @trasact_errors.each do |e|
            @error_string << (e.to_s + "\n")
          end
          #send @error_string via email to @appointment.user
          flash[:alert] = "Cannot confirm appointment, payment unsuccesful.\n" + @error_string  
          return redirect_to users_url(anchor: "appointment")
        end
      end
      
      @appointment.save validate: false
      UserMailer.delay.appointment_confirmed_notification(@appointment, @appointment.user)
      UserMailer.delay.appointment_confirmed_notification(@appointment, @appointment.expert)
      
      # remove any previous worker instances 
      @appointment.sidekiqjobs.each do |s|
        Sidekiq::Status.cancel s.sidekiq_id  
      end
      @appointment.sidekiqjobs.clear
      #create a reminder worker task and a appointment completed task
      if @appointment.time - Time.now < 3600
        @appointment.sidekiqjobs.create(sidekiq_id: ApptReminder.perform_at(Time.now + 1.minute, @appointment.id))
      else
        @appointment.sidekiqjobs.create(sidekiq_id: ApptReminder.perform_at(@appointment.time - 1.hours, @appointment.id))
      end
      
      @appointment.sidekiqjobs.create(sidekiq_id: ApptCompleted.perform_at(@appointment.time + @appointment.duration.minutes, @appointment.id))
      redirect_to expert_appointment_url(current_user.id, @appointment.id), notice: I18n.t("appointment.confirmed")
    end
  end

  def new_hangout
    
    if params[:apptID].present? && params[:hangoutUrl].present?
      @appointment = Appointment.find(params[:apptID])
      @appointment.hangout_url = params[:hangoutUrl]
      @appointment.is_hangout_active = true
      @appointment.hangout_start_time = Time.now
      @appointment.save validate: false
    end
    
    respond_to do |format|
      
      msg = { :status => "ok", :message => "Success!", :html => "<b>...</b>" }
      
      format.json  { render :json => msg }
    end
  end
  
  def new_conversation
    
    @appointment = Appointment.find(params[:id])
    @message = params[:message_post]
    
    if @appointment.message_id.nil?
      @user = User.find(@message[:recipient_id])
      @receipt = current_user.send_message(@user, @message[:body], @message[:subject], true, nil)
      @appointment.message_id = @receipt.conversation.id
      @appointment.save validate: false
    else
      @conversation = Conversation.find(@appointment.message_id)
      @receipt = current_user.reply_to_conversation(@conversation, @message[:body], nil, true, true, nil)
    end
    
    redirect_to expert_appointment_url(params[:expert_id], params[:id])
  end
  
  private

  def get_expert
    @expert = Expert.find_by_id(params[:expert_id])
  end

  def appointment_params
    params.require(:appointment).permit(:what_message, :tos_accepted, :hourly_rate, :time, :time_zone, :duration, :place, :subject, :description, :online)
  end

  def form_data
    @available_skills = AvailableTag.skills.map { |e| [e.name.downcase, e.name.downcase] }
    @appointment = Appointment.find_by_id(params[:id]) || @expert.appointments.new
    @duration_options = (30..360).step(30).map { |d| [ d < 60 ? "#{d.to_s} minutes" : "#{(d/60.round(1)).to_s} #{"hour".pluralize(d/60.round(1))}" , d.to_s ] }
    @default_duration = @appointment.duration || (params[:duration].to_i == 0 ? 30 : params[:duration].to_i) 
    @hourly_rate_in_credit = @appointment.hourly_rate.present? ?  @appointment.hourly_rate : @appointment.expert.hourly_rate_in_credit
    @user_id = params[:user_id]
    @request_id = params[:request_id]
  end
  
  def persist_data
    @duration_options = (30..360).step(30).map { |d| [ d < 60 ? "#{d.to_s} minutes" : "#{(d/60.round(1)).to_s} #{"hour".pluralize(d/60.round(1))}" , d.to_s ] }
    @default_duration = @appointment.duration || (params[:duration].to_i == 0 ? 30 : params[:duration].to_i) 
    @hourly_rate_in_credit = @appointment.hourly_rate.present? ?  @appointment.hourly_rate : @appointment.expert.hourly_rate_in_credit
    @user_id = params[:user_id]
    @request_id = params[:request_id]
  end
  
  def get_user
    if current_user.expert?
      unless params[:expert_id].to_i == current_user.id
        current_user
      else
        User.find_by_id(params[:appointment][:user_id])
      end
    else
      current_user
    end
  end

  def confirm_appointment_for_current_user
    if current_user.expert?
      unless params[:expert_id].to_i == current_user.id
        @appointment.user_confirmed = true
        @mail_to = @appointment.expert
      else
        @appointment.expert_confirmed = true
        @mail_to = @appointment.user  
      end
    else
      @appointment.user_confirmed = true
      @mail_to = @appointment.expert
    end
  end

  def time_zone(&block)
    Time.use_zone(params[:appointment][:time_zone], &block)
  end
    
end
