# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ErrorsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:index]

      def index
        render json: Api::V2::ErrorSerializer.new(errors)
      end

      private

      def result_set
        @result_set ||= Journey::ResultSet.find(params[:result_set_id])
      end

      def errors
        Journey::Error.where(result_set: result_set)
      end
    end
  end
end
