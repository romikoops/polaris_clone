# frozen_string_literal: true

module Api
  module V2
    class ValidationsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[create]

      def create
        render json: validated_validation_params.errors.to_h, status: :unprocessable_entity and return if validated_validation_params.errors.present?

        validator = Wheelhouse::ValidationService.new(request: offer_request)
        validator.validate
        render json: ValidationErrorSerializer.new(ValidationErrorDecorator.decorate_collection(validator.errors))
      end

      private

      def query
        @query ||= OfferCalculator::Service::QueryGenerator.new(
          source: query_source,
          client: current_user,
          creator: current_user,
          params: validation_params,
          persist: false
        ).query
      end

      def offer_request
        @offer_request ||= OfferCalculator::Request.new(
          query: query,
          params: validation_params,
          persist: false,
          pre_carriage: validation_params.dig("origin", "nexus_id").blank?,
          on_carriage: validation_params.dig("destination", "nexus_id").blank?
        )
      end

      def validation_params
        @validation_params ||= Wheelhouse::QueryParamTransformationService.new(params: validation_service_params).perform
      end

      def validated_validation_params
        @validated_validation_params ||= Api::ValidationContract.new.call(query_params.to_h)
      end

      def query_params
        params.permit(
          :originId,
          :destinationId,
          :loadType,
          :parentId,
          :aggregated,
          :billable,
          :cargoReadyDate,
          items: [
            :cargoClass,
            :stackable,
            :dangerous,
            :colliType,
            :quantity,
            :width,
            :height,
            :length,
            :volume,
            :weight,
            :id,
            { commodities: %i[description hsCode imoClass] }
          ]
        )
      end

      def validation_service_params
        validated_validation_params
          .to_h
          .deep_transform_keys { |key| key.to_s.underscore.to_sym }
      end

      def query_source
        current_user ? doorkeeper_application : Doorkeeper::Application.find_by(name: "siren")
      end
    end
  end
end
