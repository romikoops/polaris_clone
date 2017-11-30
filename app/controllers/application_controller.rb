class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ApplicationError

  rescue_from ApplicationError do |ex|
    response_handler(ex)
  end

  def response_handler(res)
    if res.kind_of? StandardError
      error_handler(res)
    else
      success_handler(res)
    end
  end

  def error_handler(e)
    code = e.config[:http_code] || 500
    render status: code, json: { success: false, error: e.message, code: e.code }
  end

  def success_handler(e)
    render status: 200, json: { success: true, data: e }
  end
end
