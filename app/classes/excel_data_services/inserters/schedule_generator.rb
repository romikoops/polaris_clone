# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class ScheduleGenerator < ExcelDataServices::Inserters::Base
      CLOSING_DATE_BUFFER = 4
      STANDARD_PERIOD = 3.months
      def perform
        data.each do |datum|
          generate_schedules(ExcelDataServices::Rows::ScheduleGenerator.new(row_data: datum, organization: organization))
        end

        stats
      end

      private

      def generate_schedules(row)
        mode_of_transport = row.mode_of_transport
        transshipment = row.transshipment
        itinerary_name = row.itinerary_name
        itineraries = Itinerary.where(
          organization_id: organization.id,
          transshipment: transshipment,
          name: itinerary_name
        )
        itineraries = itineraries.where(mode_of_transport: mode_of_transport) if mode_of_transport.present?
        return if itineraries.blank?

        itineraries.find_in_batches do |itinerary_batch|
          itinerary_batch.each do |itinerary|
            generate_from_itinerary(itinerary: itinerary, row: row)
          end
        end
      end

      def generate_from_itinerary(itinerary:, row:)
        tenant_vehicle_ids = relevant_tenant_vehicle_ids(itinerary, row)
        stops_in_order = itinerary.stops.order(:index)
        finish_date = Date.today + STANDARD_PERIOD
        tenant_vehicle_ids.each do |tv_id|
          trip_results = itinerary.generate_weekly_schedules(
            stops_in_order: stops_in_order,
            steps_in_order: [row.transit_time],
            start_date: DateTime.now,
            end_date: finish_date,
            ordinal_array: row.ordinals,
            tenant_vehicle_id: tv_id,
            closing_date_buffer: CLOSING_DATE_BUFFER,
            load_type: row.cargo_class.to_s
          )
          trip_results.each { |trip| add_stats(trip, row.nr, true) }
        end
      end

      def relevant_tenant_vehicle_ids(itinerary, row)
        tenant_vehicle_ids = Pricings::Pricing
                             .where(itinerary_id: itinerary.id)
                             .for_load_type(row.cargo_class.to_s)
                             .pluck(:tenant_vehicle_id)

        query = Legacy::TenantVehicle.where(id: tenant_vehicle_ids, organization_id: organization.id)
        carrier = row.carrier
        service_level = row.service_level

        if carrier
          carrier = carrier_from_code(name: carrier)
          query = query.where(carrier_id: carrier&.id)
        end

        query = query.where(name: service_level) if service_level

        query.pluck(:id)
      end
    end
  end
end
