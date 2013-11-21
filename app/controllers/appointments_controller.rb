class AppointmentsController < ApplicationController
  before_filter :authenticate_user!, except: [:new_hangout]
  around_filter :time_zone, if: :authenticate_user!, only: [:create, :update]
  
  before_filter :get_expert
  before_filter :form_data, only: [:new, :edit]

  def new
    
    if current_user.expert?
      unless current_user.braintree_merchant_id.present? && ( current_user.braintree_merchant_status.present? && current_user.braintree_merchant_status == "active")
        flash[:alert] = "Cannot create appointment, need to have and active merchant account on file"
        return redirect_to users_url(anchor: "credit") 
      end
      
      unless (params[:expert_id].to_i == current_user.id) 
        unless current_user.braintree_id.present? && current_user.braintree_token.present?
          flash[:alert] = "Cannot create appointment, need to have credit card on file"
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
      confirm_appointment_for_current_user
      
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
        redirect_to expert_appointment_url(id: @appointment.id), notice: I18n.t("appointment.create.success"), error: @appointment.errors
      else
        redirect_to new_expert_appointment_url(params[:appointment]), notice: I18n.t("appointment.create.failure"), alert: @appointment.errors.full_messages.to_sentence
      end
    rescue Exception => e
      debugger
      redirect_to new_expert_appointment_url, notice: I18n.t("appointment.create.failure")
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    if current_user.expert?
      unless @appointment.expert.id == current_user.id
        @message_to = @appointment.expert
      else
        @message_to = @appointment.user  
      end
    else
      @message_to = @appointment.expert
    end
  end

  def edit
    @appointment = Appointment.find(params[:id])
    
    @hours_edit = Setting.find_by(name: "hours_edit_allowed").value
    if (@appointment.time.in_time_zone(@appointment.time_zone) - @hours_edit.to_i.hours) < Time.now
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
      @appointment.save
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
      @hours_cancellation = Setting.find_by(name: "hours_cancellation_allowed").value
      
      if (@appointment.time.in_time_zone(@appointment.time_zone) - @hours_cancellation.to_i.hours) < Time.now
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
      
      redirect_to users_url, notice: I18n.t("appointment.cancel.success")
    rescue Exception => e
      debugger
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
        
        @result = Braintree::Transaction.sale(
          :amount => @appointment.total_credit_cost,
          :merchant_account_id => @appointment.expert.braintree_merchant_id,
          :customer_id => @appointment.user.braintree_id,
          :payment_method_token => @appointment.user.braintree_token,
          :options => {
            :submit_for_settlement => true,
            :hold_in_escrow => true
          },
          :service_fee_amount => (Setting.find_by(name: "lorious_service_charge_percent").value.to_f * @appointment.total_credit_cost.to_f / 100).to_s
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
          debugger
          #send payment error message and unconfirm appointment
          flash[:alert] = "Cannot confirm appointment, payment unsuccesful."
          return redirect_to users_url(anchor: "appointment")
        end
      end
      
      @appointment.save
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
      @appointment.save
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
    @appointment = Appointment.find_by_id(params[:id]) || @expert.appointments.new
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
