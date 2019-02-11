# frozen_string_literal: true

module ExcelDataServices
  module Row
    class Pricing < Base
      def itinerary_name
        @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
      end

      def stop_names
        @stop_names ||= [data[:origin], data[:destination]]
      end

      def transit_time
        @transit_time ||= data[:transit_time]
      end
    end
  end
end
