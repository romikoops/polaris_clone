# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class TruckingAvailabilityController < ApiController
      def index
        trucking_types = Hash.new { |h, k| h[k] = [] }
        hub_ids = []
        trucking_pricings.each do |trucking_pricing|
          hub_id = trucking_pricing.hub_id
          truck_type = trucking_pricing.truck_type

          hub_ids << hub_id
          trucking_types[hub_id] << truck_type unless trucking_types[hub_id].include?(truck_type)
        end
        nexus_ids = Legacy::Hub.where(id: hub_ids, sandbox: @sandbox).pluck(:nexus_id).uniq

        response = formatted_response(trucking_pricings, nexus_ids, hub_ids, trucking_types)
        render json: response
      end

      private

      def trucking_pricings
        @trucking_pricings ||= begin
          area_results = ::Trucking::Queries::Availability.new(trucking_args).perform
          distance_results = ::Trucking::Queries::Distance.new(trucking_args).perform
          area_results | distance_results
        end
      end

      def formatted_response(trucking_pricings, nexus_ids, hub_ids, trucking_types)
        {
          trucking_available: !trucking_pricings.empty?,
          nexus_ids: nexus_ids.compact,
          hub_ids: hub_ids.compact,
          truck_type_object: trucking_types
        }.deep_transform_keys { |k| k.to_s.camelize(:lower) }
      end

      def trucking_args
        {
          tenant_id: trucking_params[:tenant_id],
          load_type: trucking_params[:load_type],
          address: address,
          hub_ids: trucking_params[:hub_ids].split(',').map(&:to_i),
          carriage: trucking_params[:carriage],
          klass: Trucking::Trucking,
          sandbox: @sandbox,
          order_by: base_pricing_enabled ? 'group_id' : 'user_id'
        }
      end

      def base_pricing_enabled
        Tenants::ScopeService.new(
          target: ::Tenants::User.find_by(legacy_id: current_user&.id),
          tenant: ::Tenants::Tenant.find_by(legacy_id: current_tenant&.id)
        ).fetch(:base_pricing)
      end

      def address
        address = Geocoder.search([trucking_params[:lat].to_f, trucking_params[:lng].to_f]).first
        return unless address

        OpenStruct.new(
          latitude: trucking_params[:lat].to_f,
          longitude: trucking_params[:lng].to_f,
          zipcode: address.postal_code,
          city_name: address.city,
          country: OpenStruct.new(code: address.country_code)
        )
      end

      def trucking_params
        params.permit(:lat, :lng, :hub_ids, :load_type, :carriage, :tenant_id)
      end
    end
  end
end
