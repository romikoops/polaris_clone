# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class ScheduleGenerator < ExcelDataServices::Inserters::Base
      CLOSING_DATE_BUFFER = 4
      STANDARD_PERIOD = 3.months
      def perform
        data.each do |params|
          generate_schedules(params)
        end

        stats
      end

      private

      def generate_schedules(params)
        itineraries = Itinerary.where(
          tenant_id: tenant.id,
          transshipment: params[:transshipment],
          name: "#{params[:origin]} - #{params[:destination]}",
          sandbox: @sandbox
        )
        itineraries = itineraries.where(mode_of_transport: params[:mot]) if params[:mot]

        return if itineraries.blank?

        itineraries.find_in_batches do |itinerary_batch|
          itinerary_batch.each do |itinerary|
            tenant_vehicle_ids = relevant_tenant_vehicle_ids(itinerary, params)
            stops_in_order = itinerary.stops.where(sandbox: @sandbox).order(:index)
            finish_date = Date.today + STANDARD_PERIOD
            tenant_vehicle_ids.each do |tv_id|
              trip_results = itinerary.generate_weekly_schedules(
                stops_in_order: stops_in_order,
                steps_in_order: [params[:transit_time]],
                start_date: DateTime.now,
                end_date: finish_date,
                ordinal_array: params[:ordinals],
                tenant_vehicle_id: tv_id,
                closing_date_buffer: CLOSING_DATE_BUFFER,
                load_type: params[:cargo_class].to_s,
                sandbox: @sandbox
              )
              trip_results.each { |trip| add_stats(trip, true) }
            end
          end
        end
      end

      def relevant_tenant_vehicle_ids(itinerary, params)
        pricing_association = @scope[:base_pricing] ? Pricings::Pricing : Legacy::Pricing
        tenant_vehicle_ids = pricing_association
                             .where(itinerary_id: itinerary.id, sandbox: @sandbox)
                             .for_load_type(params[:cargo_class].to_s)
                             .pluck(:tenant_vehicle_id)

        query = TenantVehicle.where(id: tenant_vehicle_ids, tenant_id: tenant.id, sandbox: @sandbox)

        if params[:carrier]
          carrier = carrier_from_code(name: params[:carrier])
          query = query.where(carrier_id: carrier&.id)
        end

        query = query.where(name: params[:service_level]) if params[:service_level]

        query.pluck(:id)
      end
    end
  end
end
