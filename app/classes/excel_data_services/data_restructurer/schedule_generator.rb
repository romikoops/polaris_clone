# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    module ScheduleGenerator
      def self.build_charge_params(data)
        all_charge_params = []
        data.values.each do |per_sheet_values|
          all_charge_params << per_sheet_values[:rows_data].map do |row_data|
            dates_to_ordinals(row_data)
            parse_cargo_class(row_data)
            row_data
          end
        end
        all_charge_params.flatten
      end

      def self.restructure_data(data)
        build_charge_params(data[:data])
      end

      def self.dates_to_ordinals(row_data)
        ordinal_lookup = {
          MONDAY: 1,
          TUESDAY: 2,
          WEDNESDAY: 3,
          THURSDAY: 4,
          FRIDAY: 5,
          SATURDAY: 6,
          SUNDAY: 0
        }.with_indifferent_access

        row_data[:ordinals] = row_data.delete(:etd_days)
                                      .split(',')
                                      .map(&:strip)
                                      .map { |string| ordinal_lookup[string.upcase] }
      end

      def self.parse_cargo_class(row_data)
        row_data[:cargo_class] = case row_data[:cargo_class].downcase
                                 when /^(lcl|cargo_item)$/
                                   'cargo_item'
                                 when /^(fcl|container)$/
                                   'container'
                                 end
      end
    end
  end
end
