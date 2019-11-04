# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Pricing < Base
      def destination
        @destination ||= data[:destination]
      end

      def destination_locode
        @destination_locode ||= data[:destination_locode]
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

      def internal
        @internal ||= data[:internal]
      end

      def notes
        @notes ||= data[:notes]
      end

      def origin
        @origin ||= data[:origin]
      end

      def origin_locode
        @origin_locode ||= data[:origin_locode]
      end
    end
  end
end
