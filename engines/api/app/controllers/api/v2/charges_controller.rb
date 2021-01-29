# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ChargesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:index]

      def index
        render json: Api::V2::ChargeSerializer.new(
          Api::V2::LineItemDecorator.decorate_collection(line_items)
        )
      end

      private

      def line_items
        Journey::LineItem.where(line_item_set: line_item_set)
      end

      def line_item_set
        Journey::LineItemSet.where(result: result)
      end

      def result
        Journey::Result.find(params[:result_id])
      end
    end
  end
end
