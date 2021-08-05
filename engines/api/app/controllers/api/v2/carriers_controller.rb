# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class CarriersController < ApiController
      def index
        render json: Api::V2::CarrierSerializer.new(carriers)
      end

      def show
        render json: Api::V2::CarrierSerializer.new(carrier)
      end

      private

      def carrier
        @carrier ||= ::Routing::Carrier.find(params[:id])
      end

      def carriers
        @carriers ||= ::Routing::Carrier.all
      end
    end
  end
end
