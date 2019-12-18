# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class ScheduleGenerator < ExcelDataServices::Restructurers::Base
      ORDINALS_LOOKUP = {
        MONDAY: 1,
        TUESDAY: 2,
        WEDNESDAY: 3,
        THURSDAY: 4,
        FRIDAY: 5,
        SATURDAY: 6,
        SUNDAY: 0
      }.freeze

      def perform
        { 'ScheduleGenerator' => build_charge_params }
      end

      def build_charge_params
        data[:rows_data].map do |row_data|
          dates_to_ordinals(row_data)
          parse_cargo_class(row_data)
          row_data
        end
      end

      def dates_to_ordinals(row_data)
        row_data[:ordinals] =
          row_data.delete(:etd_days)
                  .split(',')
                  .map { |string| ORDINALS_LOOKUP[string.strip.upcase.to_sym] }
      end

      def parse_cargo_class(row_data)
        row_data[:cargo_class] =
          case row_data[:cargo_class].downcase
          when /^(lcl|cargo_item)$/
            'cargo_item'
          when /^(fcl|container)$/
            'container'
          end
      end
    end
  end
end
