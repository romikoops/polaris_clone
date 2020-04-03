# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Schedules < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          itinerary = find_itinerary(params)
          next if itinerary.blank?

          trip = init_trip_with_layovers(params, itinerary)
          add_stats(trip)

          trip.save
        end

        stats
      end

      private

      def find_itinerary(params)
        Itinerary.find_by(
          tenant: tenant,
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
          tenant_vehicle_id: find_tenant_vehicle_id(params),
          layovers: generate_layovers(itinerary, params)
        )
      end

      def find_tenant_vehicle_id(params)
        carrier = carrier_from_code(name: params[:carrier]) if params[:carrier].present?

        TenantVehicle.find_by(
          tenant: tenant,
          name: params[:service_level],
          carrier: carrier,
          mode_of_transport: params[:mode_of_transport]
        ).id
      end

      def generate_layovers(itinerary, params)
        itinerary.stops.map do |stop|
          stop_index_zero = stop.index.zero?
          Legacy::Layover.new(
            stop_id: stop.id,
            stop_index: stop.index,
            closing_date: params[:closing_date],
            itinerary_id: stop.itinerary_id,
            eta: stop_index_zero ? nil : params[:eta],
            etd: stop_index_zero ? params[:etd] : nil
          )
        end
      end
    end
  end
end
