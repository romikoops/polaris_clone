class NotificationsController < ApplicationController
  include NotificationTools
  include Response
  def index
    messages = get_messages_for_user(current_user)
    response_handler(messages)
  end

  def send_message
    message = params[:message]
    resp = add_message(current_user, message)
    response_handler(resp)
  end
end
