# frozen_string_literal: true

module Api
  module V1
    class ValidationsController < ApiController
      def create
        validator = Wheelhouse::ValidationService.new(
          request: offer_request
        )
        validator.validate
        render json: ValidationErrorSerializer.new(validator.errors)
      end

      private

      def query
        @query ||= OfferCalculator::Service::QueryGenerator.new(
          source: doorkeeper_application,
          client: client,
          creator: current_user,
          params: query_params,
          persist: false
        ).query
      end

      def offer_request
        @offer_request ||= OfferCalculator::Request.new(
          query: query,
          params: query_params,
          persist: false
        )
      end

      def client
        Users::Client.find_by(id: user_param[:user_id])
      end

      def user_param
        params.require(:quote).permit(:user_id)
      end

      def query_params
        cargo_params.to_h.merge(routing).merge(load_type: load_type)
      end

      def load_type
        params.require(:quote).permit(:load_type)[:load_type]
      end

      def routing_params
        params.require(:quote).permit(
          origin: address_params,
          destination: address_params
        )
      end

      def routing
        {
          origin: routing_params[:origin].to_h,
          destination: routing_params[:destination].to_h
        }
      end

      def cargo_params
        cargo_items_attributes = %i[id payload_in_kg width length
          height quantity total_weight total_volume
          stackable cargo_item_type_id dangerous_goods cargo_class]
        params.require(:shipment_info).permit(cargo_items_attributes: cargo_items_attributes,
                                              containers_attributes: %i[id size_class quantity
                                                payload_in_kg dangerous_goods cargo_class])
      end

      def address_params
        %i[name zip_code number city country full_address latitude longitude nexus_id nexus_name]
      end
    end
  end
end
