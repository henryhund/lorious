class PaymentsController < ApplicationController
  before_filter :authenticate_user!, except: [:webhooks]
  
  def new
  end
  
  def repeat
  end
  
  def webhooks
    challenge = request.params["bt_challenge"]
    challenge_response = Braintree::WebhookNotification.verify(challenge)
    render xml: challenge_response
  end
  
  def new_merchant
    @result = Braintree::MerchantAccount.create(
      :applicant_details => {
        :first_name => Braintree::Test::MerchantAccount::Approve,
        :last_name => "Bloggs",
        :email => "joe@14ladders.com",
        :phone => "5551112222",
        :address => {
          :street_address => "123 Credibility St.",
          :postal_code => "60606",
          :locality => "Chicago",
          :region => "IL"
        },
        :date_of_birth => "1980-10-09",
        :ssn => "123-00-1234",
        :routing_number => params[:number],
        :account_number => params[:account]
        #:routing_number => "121181976",
        #:account_number => "43759348798"
      },
      :tos_accepted => true,
      :master_merchant_account_id => "gqzd8vqh3yx986ts"
      #:id => "blue_ladders_store" optional
    )
    debugger
    redirect_to repeat_payment_url
  end
  
  def temp
    
    @result = Braintree::MerchantAccount.create(
      :applicant_details => {
        #:first_name => Braintree::Test::MerchantAccount::Approve,
        :first_name => "TEST",
        :last_name => "Bloggs",
        :email => "joe@14ladders.com",
        :phone => "5551112222",
        :address => {
          :street_address => "123 Credibility St.",
          :postal_code => "60606",
          :locality => "Chicago",
          :region => "IL"
        },
        :date_of_birth => "1980-10-09",
        :ssn => "123-00-1234",
        :routing_number => "1234567890",
        :account_number => "43759348798"
      },
      :tos_accepted => true,
      :master_merchant_account_id => "gqzd8vqh3yx986ts"
      #:id => "blue_ladders_store" optional
    )
    
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
      case @result.transaction.amount
      when 140
        @credit.amount = 150  
      when 95
        @credit.amount = 100
      when 50
        @credit.amount = 50
      else
        @credit.amount = @result.transaction.amount
      end
      
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
      
      #insert into transactions table  @result.transaction.id  @result.transaction.amount @result.transaction.created_at
    else
      @amount = @result.params[:transaction][:amount].to_i 
      render :action => "new"
    end
  end
  
  def type1
    @amount = 50
    render :action => "new"
  end
  
  def type2
    @amount = 95
    render :action => "new"
  end
  
  def type3
    @amount = 140
    render :action => "new"
  end
  protected
  
end