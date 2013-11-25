class Users::CreditsController < ApplicationController
  layout false
  
  def transactions
    @transactions = current_user.transactions_made.order(:created_at => :desc)
  end
  
end