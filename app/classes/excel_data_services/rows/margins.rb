# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Margins < ExcelDataServices::Rows::Base
      def itinerary_name
        @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
      end

      def operator
        @operator ||= data[:operator]
      end

      def margin
        @margin ||= data[:margin]
      end

      def mode_of_transport
        @mode_of_transport ||= data.fetch(:mot, data[:mode_of_transport])
      end

      def margin_type
        key = data[:margin_type]&.downcase&.strip
        @margin_type ||= if %w[freight trucking_pre trucking_on import export].include?(key)
                           "#{key}_margin".to_sym
                         elsif key.include?('on')
                           :trucking_on_margin
                         elsif key.include?('pre')
                           :trucking_pre_margin
                         else
                           :freight_margin
                         end
      end
    end
  end
end
