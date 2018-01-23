class NotificationsController < ApplicationController
  include NotificationTools
  include Response
  def index
    messages = get_messages_for_user(current_user)
    response_handler(messages)
  end

  def send_message
    message = params[:message].as_json
    resp = add_message_to_convo(current_user, message, false)
    response_handler(resp)
  end
end
