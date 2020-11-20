# frozen_string_literal: true

module Api
  module ErrorHandler
    extend ActiveSupport::Concern

    included do
      def error_handler(exception)
        status = Rails.configuration.action_dispatch.rescue_responses[exception.class.to_s]
        status = :bad_request if exception.is_a?(ActionController::ParameterMissing)

        status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a?(Symbol)

        response = {success: false, message: exception, status: status, code: status_code}
        render json: response, status: status_code
      end
    end
  end
end
