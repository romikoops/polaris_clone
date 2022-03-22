# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ChargesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:index]

      def index
        render json: Api::V2::ChargeSerializer.new(
          Api::V2::LineItemDecorator.decorate_collection(line_items, context: decorator_context)
        )
      end

      private

      def line_items
        Journey::LineItem.where(line_item_set: line_item_set)
      end

      def line_item_set
        Journey::LineItemSet.where(result: result).order(created_at: :desc).first
      end

      def result
        Journey::Result.find(charges_params[:result_id])
      end

      def charges_params
        params.permit(:result_id, :currency)
      end

      def decorator_context
        { currency: charges_params[:currency] }.compact
      end
    end
  end
end
