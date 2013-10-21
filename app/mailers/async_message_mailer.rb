class AsyncMessageMailer < MessageMailer
  
  def send_email(message, receiver)
    if message.conversation.messages.size > 1
      MessageMailer.delay.reply_message_email(message,receiver)
    else
      MessageMailer.delay.new_message_email(message,receiver)
    end
  end
end