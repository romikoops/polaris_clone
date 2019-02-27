# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Pricing < Base
      def destination_name
        @destination_name ||= data[:destination_name]
      end

      def itinerary_name
        @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
      end

      def hw_rate_basis
        @hw_rate_basis ||= data[:hw_rate_basis]
      end

      def hw_threshold
        @hw_threshold ||= data[:hw_threshold]
      end

      def origin_name
        @origin_name ||= data[:origin_name]
      end
    end
  end
end
