# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class OffersController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:create]

      def create
        render json: Api::V2::OfferSerializer.new(
          Api::V2::OfferDecorator.new(new_offer)
        )
      end

      private

      def new_offer
        Wheelhouse::OfferBuilder.offer(results: Journey::Result.where(id: new_offer_params[:resultIds]))
      end

      def new_offer_params
        params.require(:offer).permit({resultIds: []})
      end
    end
  end
end
