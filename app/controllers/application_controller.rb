require "#{Rails.root}/app/classes/application_error.rb"

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Response

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
end
