class DisburseFunds
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }
  #Task to disburse funds 48 hours after appointment has been completed, Note: if trasaction has been put on hold
  #from the control_panel funds will not be automatically disbursed
  def perform
    @released_success=[]
    @released_failed=[]
    @exceptions = []
    Appointment.find(:all, :conditions => ["time < ? AND time > ? AND appt_state = ?", 2.days.ago, 30.days.ago, "completed"]).each do |appointment|
      
      if appointment.credit_transaction.present? && !appointment.credit_transaction.is_request_hold?
        begin
          @credit_transaction = appointment.credit_transaction
          @transaction = Braintree::Transaction.find(appointment.credit_transaction.transaction_id)
          
          if @transaction.present?
            #update status of transaction
            @credit_transaction.transaction_status = @transaction.status
            @credit_transaction.transaction_escrow_status = @transaction.escrow_status 
            @credit_transaction.save validate: false #to make sure nothing prevents transaction status update
          
            #if transaction status is "settled" and escrow status is "held" we can proceed to release the funds
            if @transaction.status == "settled" && @transaction.escrow_status == "held"
              begin
                @result = Braintree::Transaction.release_from_escrow(@transaction.id)
                #release successful
                if @result.success?
                  @released_success.push(@credit_transaction)
                  @credit_transaction.transaction_escrow_status = @result.escrow_status rescue "release_pending" #update escrow status to release pending
                  @credit_transaction.save validate: false
                else
                  @error_string = ""
                  @trasact_errors = @result.errors.map { |a| a.message} 
                  @trasact_errors.each do |e|
                    @error_string << ( @result.params[:id] + ": " + e.to_s + "\n")
                  end
                  @released_failed.push(@credit_transaction)
                  @exceptions.push(@error_string)
                end
              rescue Exception => e
                #do nothing, transaction is invalid manual intervention may be required
                @released_failed.push(@credit_transaction)
                @exceptions.push(e.message)
              end 
            end
          else
            #transaction not found
            @released_failed.push(@credit_transaction) 
          end
        rescue Exception => e
          #invalid transaction skip 
          @released_failed.push(@credit_transaction) 
          @exceptions.push(e.message)
        end
      end  
    end
    
    UserMailer.daily_disbursement_batch_report(@released_failed, @released_success, @exceptions).deliver
  end
end