# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module MissingValues
      class MaxDimensions < ExcelDataServices::Validators::MissingValues::Base
        private

        def check_single_data(row)
          check_row_requirements(row)
        end

        def check_row_requirements(row)
          row_requirements(row).each do |row_key|
            next if row[row_key].present?

            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "Missing value for #{row_key == :cargo_class ? 'LOAD_TYPE' : row_key.upcase}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues
            )
          end
        end

        def row_requirements(row)
          if row[:cargo_class]&.include?('fcl')
            %i[payload_in_kg cargo_class]
          else
            %i[dimension_z dimension_x dimension_y payload_in_kg chargeable_weight cargo_class]
          end
        end
      end
    end
  end
end
