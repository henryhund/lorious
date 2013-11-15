class CreditTransaction < ActiveRecord::Base
  
  belongs_to :transacter, class_name: "User"
  belongs_to :transacted, class_name: "User"
  
  attr_accessor :state_change
  has_one :appointment, foreign_key: "transaction_id", dependent: :destroy
  
  before_save :save_state_change
  
  def amount_with_sign
    added ? amount : -amount
  end
  
  def save_state_change
    
    if @state_change.present?
      @transaction = Braintree::Transaction.find(self.transaction_id)
      
      case @state_change
      when "refund"
        if @transaction.status == "submitted_for_settlement"
          # can void
          @result = Braintree::Transaction.void(@transaction.id)
          
          if @result.success?
            self.transaction_status = @result.transaction.status
          else
            @trasact_errors = @result.errors.map { |a| a.message} 
            @trasact_errors.each do |e|
              self.errors[:base] << (e.to_s + "\n")
            end   
          end
        elsif @transaction.status == "settled"
          # will have to refund it
          @result = Braintree::Transaction.refund(@transaction.id)
          
          if @result.success?
            @credit = CreditTransaction.new
            @credit.amount = @result.transaction.amount
            @credit.added = true
            @credit.transacted_id = self.appointment.user.id
            @credit.transacter_id = self.appointment.user.id
            @credit.transaction_id = @result.transaction.id
            @credit.created_at = @result.transaction.created_at
            @credit.transaction_status = @result.transaction.status
            @credit.description = "Transaction ID: " + @result.transaction.id + " Amount Credited: $" + @result.transaction.amount.to_s
            @credit.save
          else
            @trasact_errors = @result.errors.map { |a| a.message} 
            @trasact_errors.each do |e|
              self.errors[:base] << (e.to_s + "\n")
            end   
          end  
        else
          self.errors[:base] << "Transaction not eligible for Refund. Please contact Administration."  
        end
      when "hold"
        self.is_request_hold = self.is_request_hold? ? 0 : 1
      when "release"
        
        @result = Braintree::Transaction.release_from_escrow(@transaction.id)  
        
        if @result.success?
          self.transaction_status = @result.transaction.status
          self.transaction_escrow_status = @result.transaction.escrow_status
        else
          @trasact_errors = @result.errors.map { |a| a.message} 
          @trasact_errors.each do |e|
            self.errors[:base] << (e.to_s + "\n")
          end  
        end        
        
      end
    end
  end
  
end
