class Users::RequestsController < ApplicationController
  
  layout false
  
  def new_request
    @requests = current_user.requests_made.where(request_state: "new")
  end
  
  def withdrawn
    @requests = current_user.requests_made.where(request_state: "withdraw")
  end
  
  def completed
    @requests = current_user.requests_made.where(request_state: "complete")
  end
end