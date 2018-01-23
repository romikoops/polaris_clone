class NotificationsController < ApplicationController
  include NotificationTools
  include Response
  def index
    if current_user
      messages = get_messages_for_user(current_user)
      response_handler(messages)
    else
      response_handler(true)
    end
   
  end

  def send_message
    message = params[:message].as_json
    resp = add_message_to_convo(current_user, message, false)
    response_handler(resp)
  end
end
