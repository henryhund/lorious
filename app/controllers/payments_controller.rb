class PaymentsController < ApplicationController
  def new
    @amount = calculate_amount
  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    
    if @result.success?
      current_user.braintree_id = @result.transaction.customer_details.id
      current_user.braintree_last4 = @result.transaction.credit_card_details.last_4
      current_user.save
      
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
      @credit.created_at = @result.transaction.created_at
      @credit.description = "Transaction ID: " + @result.transaction.id + " Amount Charged: $" + @result.transaction.amount.to_s
      
      begin
        @credit.save
      rescue Exception => e
        render :action => "new"
      else
        render :action => "confirm"
      end
      
      #insert into transactions table  @result.transaction.id  @result.transaction.amount @result.transaction.created_at
    else
      
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