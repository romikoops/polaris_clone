# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Schedules < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          itinerary = find_itinerary(params)
          next if itinerary.blank?

          trip = init_trip_with_layovers(params, itinerary)
          add_stats(trip, params[:row_nr])

          trip.save
        end

        stats
      end

      private

      def find_itinerary(params)
        Legacy::Itinerary.find_by(
          organization: organization,
          name: "#{params[:from]} - #{params[:to]}",
          transshipment: params[:transshipment],
          mode_of_transport: params[:mode_of_transport]
        )
      end

      def init_trip_with_layovers(params, itinerary)
        Legacy::Trip.new(
          vessel: params[:vessel],
          voyage_code: params[:voyage_code],
          load_type: params[:load_type],
          start_date: params[:etd],
          closing_date: params[:closing_date],
          end_date: params[:eta],
          itinerary: itinerary,
          tenant_vehicle_id: find_tenant_vehicle_id(params)
        )
      end

      def find_tenant_vehicle_id(params)
        carrier = carrier_from_code(name: params[:carrier]) if params[:carrier].present?

        Legacy::TenantVehicle.find_by(
          organization: organization,
          name: params[:service_level],
          carrier: carrier,
          mode_of_transport: params[:mode_of_transport]
        ).id
      end
    end
  end
end
