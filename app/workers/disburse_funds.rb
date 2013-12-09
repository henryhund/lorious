class DisburseFunds
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }
  #Task to disburse funds 48 hours after appointment has been completed, Note: if trasaction has been put on hold
  #from the control_panel funds will not be automatically disbursed
  def perform
    Appointment.find(:all, :conditions => ["time < ? AND appt_state = ?", 2.days.ago, "completed"]).each do |appointment|
      if !appointment.credit_transaction.is_request_hold?
        @transaction = Braintree::Transaction.find(appointment.credit_transaction.transaction_id)
      
        #update status of transaction
        @credit_transaction = appointment.credit_transaction
        @credit_transaction.transaction_status = @transaction.status
        @credit_transaction.transaction_escrow_status = @transaction.escrow_status 
        @credit_transaction.save validate: false #to make sure nothing prevents transaction status update
        
        #if transaction status is "settled" and escrow status is "held" we can proceed to release the funds
        if @transaction.status == "settled" && @transaction.transaction_escrow_status == "held"
          begin
            @result = Braintree::Transaction.release_from_escrow(@transaction.id)
          rescue Exception => e
            #do nothing, transaction is invalid manual intervention may be required
          else
            #release successful
            if @result.success?
              @credit_transaction.transaction_escrow_status = @result.escrow_status #update escrow status to release pending
              @credit_transaction.save validate: false
            end
            
          end 
          
        end
        
      end
          
    end
  end
end