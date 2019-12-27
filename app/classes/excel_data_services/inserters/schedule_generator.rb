# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class ScheduleGenerator < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          generate_schedules(params)
        end

        stats
      end

      private

      def generate_schedules(params)
        itinerary = Itinerary.find_by(
          tenant_id: tenant.id,
          name: "#{params[:origin].titleize} - #{params[:destination].titleize}",
          sandbox: @sandbox
        )

        return nil unless itinerary

        tenant_vehicle_ids = relevant_tenant_vehicle_ids(itinerary, params)
        stops_in_order = itinerary.stops.where(sandbox: @sandbox).order(:index)
        today = Date.today
        finish_date = today + 3.months
        tenant_vehicle_ids.each do |tv_id|
          trip_results = itinerary.generate_weekly_schedules(
            stops_in_order: stops_in_order,
            steps_in_order: [params[:transit_time]],
            start_date: DateTime.now,
            end_date: finish_date,
            ordinal_array: params[:ordinals],
            tenant_vehicle_id: tv_id,
            closing_date_buffer: 4,
            load_type: params[:cargo_class].to_s,
            sandbox: @sandbox
          )
          trip_results.each { |trip| add_stats(trip, true) }
        end
      end

      def relevant_tenant_vehicle_ids(itinerary, params)
        tenant_vehicle_ids = itinerary
                             .pricings.where(sandbox: @sandbox)
                             .for_load_type(params[:cargo_class].to_s)
                             .pluck(:tenant_vehicle_id)

        query = TenantVehicle.where(id: tenant_vehicle_ids, tenant_id: tenant.id, sandbox: @sandbox)

        if params[:carrier]
          carrier = Carrier.find_by(name: params[:carrier])
          query = query.where(carrier_id: carrier&.id)
        end

        query = query.where(name: params[:service_level]) if params[:service_level]

        query.pluck(:id)
      end
    end
  end
end
