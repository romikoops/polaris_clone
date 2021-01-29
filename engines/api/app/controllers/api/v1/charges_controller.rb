# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class ChargesController < ApiController
      def show
        decorated_result = ResultDecorator.decorate(result, context: {scope: current_scope})
        render json: DetailedResultSerializer.new(decorated_result, params: {scope: current_scope})
      end

      private

      def result
        Journey::Result.find(result_params[:id])
      end

      def result_params
        params.permit(:id)
      end
    end
  end
end
