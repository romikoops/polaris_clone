# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class MaxDimensions < ExcelDataServices::Restructurers::Base
      def perform
        sheet_name = data[:sheet_name]
        restructurer_name = data[:restructurer_name]
        restructured_data = replace_nil_equivalents_with_nil(data[:rows_data])
        restructured_data = sanitize_locodes(restructured_data)
        restructured_data = downcase_values(rows_data: restructured_data, keys: [:load_type])
        restructured_data = rename_load_types_to_cargo_class(restructured_data)
        restructured_data = optional_dimensions(restructured_data)
        restructured_data = enforce_numerics(restructured_data)
        restructured_data = sanitize_service_level_and_carrier(restructured_data)
        restructured_data = expand_fcl_to_all_sizes(restructured_data)
        restructured_data = ensure_aggregate_booleans(restructured_data)

        restructured_data = restructured_data.map do |row_data|
          { sheet_name: sheet_name,
            restructurer_name: restructurer_name }.merge(row_data)
        end

        { 'MaxDimensions' => restructured_data }
      end

      def optional_dimensions(data)
        data.map do |datum|
          datum[:width] = datum[:width] || datum[:dimension_x]
          datum[:length] = datum[:length] || datum[:dimension_y]
          datum[:height] = datum[:height] || datum[:dimension_z]
          datum
        end
      end

      def enforce_numerics(data)
        data.map do |datum|
          datum[:payload_in_kg] = datum[:payload_in_kg].to_d
          if datum[:cargo_class] == 'lcl'
            datum[:chargeable_weight] = datum[:chargeable_weight].to_d
            datum[:width] = datum[:width].to_d
            datum[:length] = datum[:length].to_d
            datum[:height] = datum[:height].to_d
          end
          datum
        end
      end

      def ensure_aggregate_booleans(data)
        data.map do |datum|
          datum[:aggregate] = datum[:aggregate].nil? ? false : datum[:aggregate]
          datum
        end
      end
    end
  end
end
