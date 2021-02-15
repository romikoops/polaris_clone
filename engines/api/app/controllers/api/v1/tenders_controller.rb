# frozen_string_literal: true

require_dependency "api/application_controller"

module Api
  module V1
    class TendersController < ApiController
      def update
        updated_result = result_updater.perform
        decorated_result = ResultDecorator.decorate(updated_result, context: {scope: current_scope})
        render json: DetailedResultSerializer.new(decorated_result, params: {scope: current_scope})
      end

      private

      def result
        Journey::Result.find(update_params[:id])
      end

      def result_updater
        Api::ResultUpdater.new(result: result,
                               line_item_id: update_params[:line_item_id],
                               value: update_params[:value])
      end

      def update_params
        params.permit(:id, :line_item_id, :value)
      end
    end
  end
end
