# frozen_string_literal: true

module Response
  def json_response(object, status = :ok)
    render json: object.to_json, status: status
  end

  def error_handler(e)
    code = e.config[:http_code] || 500
    Rails.logger.debug "#{e.class} (#{e.code}): #{e.message}"

    resp = { success: false, message: e.message, code: e.code }
    json_response(resp, code)
  end

  def success_handler(res)
    json_response({ success: true, data: res }, 200)
  end
end
