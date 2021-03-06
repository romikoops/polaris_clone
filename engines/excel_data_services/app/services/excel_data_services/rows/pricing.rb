# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Pricing < ExcelDataServices::Rows::Base
      def destination_country
        @destination_country ||= data[:country_destination]
      end

      def destination_locode
        @destination_locode ||= data[:destination_locode]
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

      def origin_country
        @origin_country ||= data[:country_origin]
      end

      def origin_locode
        @origin_locode ||= data[:origin_locode]
      end

      def transit_time
        @transit_time ||= data[:transit_time]&.to_i
      end

      def wm_ratio
        @wm_ratio ||= data[:wm_ratio]&.to_i || Pricings::Pricing::WM_RATIO_LOOKUP[mode_of_transport]
      end

      def vm_ratio
        @vm_ratio ||= data[:vm_ratio] ? (data[:vm_ratio].to_d / 1000.0) : 1.0
      end

      def origin_terminal
        @origin_terminal ||= data[:origin_terminal]
      end

      def destination_terminal
        @destination_terminal ||= data[:destination_terminal]
      end
    end
  end
end
