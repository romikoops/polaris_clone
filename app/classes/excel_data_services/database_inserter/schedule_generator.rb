# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class ScheduleGenerator < Base
      include ExcelDataServices::ScheduleGeneratorTool

      def perform
        data.each do |params|
          generate_schedules(params)
        end

        stats
      end

      private

      def stat_descriptors
        %i(trips)
      end

      def generate_schedules(params)
        itinerary = Itinerary.find_by(
          tenant_id: tenant.id,
          name: "#{params[:origin].titleize} - #{params[:destination].titleize}"
        )

        return nil unless itinerary

        tenant_vehicle_ids = relevant_tenant_vehicle_ids(itinerary, params)
        stops_in_order = itinerary.stops.order(:index)
        today = Date.today
        finish_date = today + 3.months
        tenant_vehicle_ids.each do |tv_id|
          trip_results = itinerary.generate_weekly_schedules(
            stops_in_order,
            [params[:transit_time]],
            DateTime.now,
            finish_date,
            params[:ordinals],
            tv_id,
            4,
            params[:cargo_class].to_s
          )
          trip_results.each { |trip| add_stats(:trips, trip) }
        end
      end

      def relevant_tenant_vehicle_ids(itinerary, params)
        tenant_vehicle_ids = itinerary
                             .pricings
                             .for_load_type(params[:cargo_class].to_s)
                             .pluck(:tenant_vehicle_id)

        query = TenantVehicle.where(id: tenant_vehicle_ids, tenant_id: tenant.id)

        query = if params[:carrier]
                  carrier = Carrier.find_by_name(params[:carrier])
                  query.where(carrier_id: carrier.id)
                else
                  query.where(carrier_id: nil)
                end
        query = query.where(name: params[:service_level]) if params[:service_level]
        query.pluck(:id)
      end
    end
  end
end
