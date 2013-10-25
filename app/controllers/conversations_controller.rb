class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  
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
  
  def inbox
    
    @inbox = current_user.mailbox.inbox
    
    respond_to do |format|
      format.html { @inbox }
      format.json { render json: @inbox }
    end
    
  end
  
  def index
      @box = params[:box] || 'inbox'
      @messages = current_user.mailbox.inbox.paginate(:page => params[:page], :per_page => 5, :count => {:group => 'conversations.id' }) if @box == 'inbox'
      @messages = current_user.mailbox.sentbox.paginate(:page => params[:page], :per_page => 5, :count => {:group => 'conversations.id' }) if @box == 'sent'
      @messages = current_user.mailbox.trash.paginate(:page => params[:page], :per_page => 5, :count => {:group => 'conversations.id' }) if @box == 'trash'
  end

  def new
    @message = Message.new
  end

  def create_message
    @message = Message.new params.require(:message).permit!

    if @message.conversation_id
      @conversation = Conversation.find(@message.conversation_id)
      unless @conversation.is_participant?(current_user)
        flash[:alert] = "You do not have permission to view that conversation."
        return redirect_to root_path
      end
      receipt = current_user.reply_to_conversation(@conversation, @message.body, nil, true, true, @message.attachment)
    else
      unless @message.valid?
        return render :new
      end
      receipt = current_user.send_message(@message.recipients, @message.body, @message.subject, true, @message.attachment)
    end
    flash[:notice] = "Message sent."

    redirect_to conversation_path(receipt.conversation)
  end

  def show
    @conversation = Conversation.find_by_id(params[:id])
    unless @conversation.is_participant?(current_user)
      flash[:alert] = "You do not have permission to view that conversation."
      return redirect_to root_path
    end
    @message = Message.new conversation_id: @conversation.id
    current_user.mark_as_read(@conversation)
  end

  def trash
    conversation = Conversation.find_by_id(params[:id])
    if conversation
      current_user.trash(conversation)
      flash[:notice] = "Message sent to trash."
    else
      conversations = Conversation.find(params[:conversations])
      conversations.each { |c| current_user.trash(c) }
      flash[:notice] = "Messages sent to trash."
    end
    redirect_to conversations_path(box: params[:current_box])
  end

  def untrash
    conversation = Conversation.find(params[:id])
    current_user.untrash(conversation)
    flash[:notice] = "Message untrashed."
    redirect_to conversations_path(box: 'inbox')
  end

  def search
    @search = params[:search]
    @messages = current_user.search_messages(@search)
    render :index
  end
end
