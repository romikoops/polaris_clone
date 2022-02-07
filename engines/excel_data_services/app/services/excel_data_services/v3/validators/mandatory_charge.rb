# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class MandatoryCharge < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::MandatoryCharge.state(state: state)
        end

        def error_reason(row:)
          config_string = row.slice("export_charges", "import_charges", "pre_carriage", "on_carriage").entries
            .map { |key, value| "#{key}: #{value}" }.join(", ")
          "The Mandatory Charge with '#{config_string}' cannot be found."
        end

        def required_key
          "mandatory_charge_id"
        end

        def row_key
          "export_charges_row"
        end

        def col_key
          "export_charges_column"
        end
      end
    end
  end
end
