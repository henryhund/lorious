class Users::CreditsController < ApplicationController
  layout false
  
  def transactions
    @transactions = current_user.transactions_made.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 5)
    respond_to do |format|
      format.html { render "transactions"}
      format.js { render "transactions.js" }
    end
  end
  
  def accounts
  end
end