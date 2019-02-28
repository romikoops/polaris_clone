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

      def generate_schedules(params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        itinerary = Itinerary.find_by(
          tenant_id: tenant.id,
          name: "#{params[:origin].titleize} - #{params[:destination].titleize}"
        )

        return nil unless itinerary

        tenant_vehicle_ids = itinerary
                             .pricings
                             .for_load_type(params[:cargo_class].to_s)
                             .pluck(:tenant_vehicle_id)
                             .uniq
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
    end
  end
end
