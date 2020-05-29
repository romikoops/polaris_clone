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
        restructured_data = sanitize_service_level_and_carrier(data[:rows_data])
        restructured_data = parse_cargo_class(rows_data: restructured_data, key: :cargo_class)
        restructured_data = convert_days_to_ordinals(rows_data: restructured_data)
        rename_mot(rows_data: restructured_data)
      end

      def convert_days_to_ordinals(rows_data:)
        rows_data.each do |row_data|
          row_data[:ordinals] =
            row_data.delete(:etd_days)
                    .split(',')
                    .map { |string| ORDINALS_LOOKUP[string.strip.upcase.to_sym] }
        end
      end

      def rename_mot(rows_data:)
        rows_data.each do |row_data|
          row_data[:mode_of_transport] = row_data.delete(:mot)
        end
      end
    end
  end
end
