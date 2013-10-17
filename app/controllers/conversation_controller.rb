class ConversationController < ApplicationController

  def create
    recipient = User.find(params[:message_post][:recipient_id])
    respond_to do |format|
      if current_user.send_message(recipient, params[:message_post][:body], params[:message_post][:subject])
        format.js { render "valid_msg" }
      else
        format.js { render "invalid_msg", :status => :unprocessable_entity }
      end
    end
    
  end
  
end
