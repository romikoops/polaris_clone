# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Schedules < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          generate_schedules_for_import(params)
        end

        stats
      end

      private

      def generate_schedules_for_import(params)
        itinerary = itinerary_from_params(params)
        return if itinerary.blank?

        trip = Legacy::Trip.new(
          vessel: params[:vessel],
          voyage_code: params[:voyage_code],
          load_type: params[:load_type],
          start_date: params[:etd],
          closing_date: params[:closing_date],
          end_date: params[:eta],
          itinerary: itinerary,
          tenant_vehicle_id: tenant_vehicle_id(params),
          layovers: generate_layovers(itinerary, params)
        )

        add_stats(trip)

        trip.save
      end

      def itinerary_from_params(params)
        Itinerary.find_by(name: "#{params[:from]} - #{params[:to]}", mode_of_transport: params[:mode_of_transport])
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

      def tenant_vehicle_id(params)
        carrier = Carrier.find_by(name: params[:carrier]) if params[:carrier].present?
        TenantVehicle.find_by(name: params[:service_level], carrier: carrier, mode_of_transport: params[:mode_of_transport]).id
      end
    end
  end
end
