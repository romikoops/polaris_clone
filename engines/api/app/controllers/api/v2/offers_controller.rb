# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class OffersController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:create]

      def create
        render json: Api::V2::RestfulSerializer.new(new_offer)
      end

      def pdf
        render json: Api::V2::OfferSerializer.new(
          Api::V2::OfferDecorator.new(offer)
        )
      end

      def email
        offer_mailer.deliver_now
        render json: {status: 200}
      end

      private

      def offer
        Journey::Offer.find(params[:offer_id])
      end

      def new_offer
        Wheelhouse::OfferBuilder.offer(results: Journey::Result.where(id: new_offer_params[:resultIds]))
      end

      def new_offer_params
        params.require(:offer).permit({resultIds: []})
      end

      def offer_mailer
        Notifications::ClientMailer.with(
          organization: current_organization,
          offer: offer,
          user: current_user
        ).offer_email
      end
    end
  end
end
