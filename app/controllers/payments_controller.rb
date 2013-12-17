class PaymentsController < ApplicationController
  before_filter :authenticate_user!, except: [:webhooks, :webhook_process]
  skip_before_action :verify_authenticity_token, only: [:webhook_process]
  
  def new
  end
  
  def merchant
    @merchant = Merchant.new
  end
  
  def webhooks
    @challenge = request.params["bt_challenge"]
    @challenge_response = Braintree::WebhookNotification.verify(@challenge)
    render xml: @challenge_response
  end
  
  def webhook_process
    @webhook_notification = Braintree::WebhookNotification.parse(
      params[:bt_signature], params[:bt_payload]
    )
    
    if @webhook_notification.kind == "sub_merchant_account_approved"
      @merchant = Expert.find_by(braintree_merchant_id: @webhook_notification.merchant_account.id)
      if @merchant.present? 
        @merchant.braintree_merchant_status = @webhook_notification.merchant_account.status 
        @merchant.save 
        UserMailer.delay.merchant_account_approved(@merchant)
      end
    elsif @webhook_notification.kind == "sub_merchant_account_declined"
      @merchant = Expert.find_by(braintree_merchant_id: @webhook_notification.merchant_account.id)
      if @merchant.present? 
        @merchant.braintree_merchant_status = @webhook_notification.merchant_account.status  
        @merchant.braintree_merchant_status_message = @webhook_notification.message
        @merchant.save
        UserMailer.delay.merchant_account_declined(@merchant, @webhook_notification.message)
      end
    elsif @webhook_notification.kind == "transaction_disbursed"
      @transaction = CreditTransaction.find_by(transaction_id: @webhook_notification.transaction.id)
      if @transaction.present?
        @transaction.transaction_status = @webhook_notification.transaction.status || "transaction_disbursed"
        @transaction.save 
      end
    end
    
    render :text => "OK" #can be anything doesn't matter as webhook doesnt expect response
  end
  
  def new_merchant
    @merchant = Merchant.new(params.require(:merchant).permit!)
    @merchant.routing_number = 1 
    @merchant.account_number = 1 
    @merchant.ssn_last4 = 1
    
    if @merchant.valid?
      
      @result = Braintree::MerchantAccount.create(
        :applicant_details => {
          :first_name => Braintree::Test::MerchantAccount::Approve,
          #:first_name => Braintree::ErrorCodes::MerchantAccount::ApplicantDetails::DeclinedOFAC,
          :last_name => current_user.last_name,
          :email => current_user.email,
          #:phone => "5551112222",
          :address => {
            :street_address => @merchant.street_address,
            :postal_code => @merchant.postal_code,
            :locality => @merchant.locality, #city
            :region => @merchant.region#state
          },
          :date_of_birth => @merchant.date_of_birth,
          :ssn => params[:ssn_last4],
          :routing_number => params[:routing_number],
          :account_number => params[:account_number]
          #:routing_number => "121181976",
          #:account_number => "43759348798"
        },
        :tos_accepted => @merchant.tos_accepted,
        :master_merchant_account_id => "t6vvt3fvkqccvnqr"
      )
    
      if @result.success?
        flash[:alert] = I18n.t("user.payment.add_merchant.success")
        current_user.braintree_merchant_id = @result.merchant_account.id 
        current_user.braintree_merchant_status = @result.merchant_account.status
        current_user.save
        redirect_to users_url(anchor: "credit")
      else
        @errors = @result.errors.map { |a| a.message} 
        flash[:alert] = ""
        @errors.each do |e|
          flash[:alert] << (e.to_s + "\n")
        end  
        
        @merchant.routing_number = nil
        @merchant.account_number = nil 
        @merchant.ssn_last4 = nil
        render action: "merchant"
      end
    else
      flash[:alert] = I18n.t("user.payment.add_merchant.failure")
      render action: "merchant"
    end
  end
  
  def credit_card
  end
    
  def new_credit_card
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    
    if @result.success?
      current_user.braintree_id = @result.customer.id  
      current_user.braintree_last4 = @result.customer.default_credit_card.last_4
      current_user.braintree_token = @result.customer.default_credit_card.token
      current_user.save validate: false
      flash[:alert] = I18n.t("user.payment.update_credit_card.success")
      redirect_to users_url(anchor: "credit")
    else
      render action: "credit_card"    
    end
    
  end
  
  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    
    if @result.success?
      
      current_user.braintree_id = @result.transaction.customer_details.id
      current_user.braintree_last4 = @result.transaction.credit_card_details.last_4
      current_user.braintree_token = @result.transaction.credit_card_details.token
      current_user.save
      
      @update_card = Braintree::CreditCard.update(
        current_user.braintree_token,
        :options => {
          :make_default => true
        }
      )
      @credit = CreditTransaction.new
      @credit.amount = @result.transaction.amount

      @credit.added = true
      @credit.transacted_id = current_user.id
      @credit.transacter_id = current_user.id
      @credit.transaction_id = @result.transaction.id
      @credit.created_at = @result.transaction.created_at
      @credit.description = "Transaction ID: " + @result.transaction.id + " Amount Charged: $" + @result.transaction.amount.to_s
      
      begin
        @credit.save
      rescue Exception => e
      else
        render :action => "confirm"
      end

    else
      @amount = @result.params[:transaction][:amount].to_i 
      render :action => "new"
    end
  end
  
end