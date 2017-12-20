require "#{Rails.root}/app/classes/application_error.rb"

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Response

  before_action :require_authentication!
  before_action :require_non_guest_authentication!

  rescue_from ApplicationError do |error|
    response_handler(error)
  end

  def response_handler(res)
    if res.kind_of? StandardError
      error_handler(res)
    else 
      success_handler(res)
    end
  end

  def require_authentication!
    raise ApplicationError::NotAuthenticated unless user_signed_in?
  end

  def require_non_guest_authentication!
    raise ApplicationError::NotAuthenticated if current_user.guest
  end
end
