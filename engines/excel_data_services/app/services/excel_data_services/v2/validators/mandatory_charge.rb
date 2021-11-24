# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class MandatoryCharge < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::MandatoryCharge.state(state: state)
        end

        def error_reason(row:)
          config_string = row.slice("export_charges", "import_charges", "pre_carriage", "on_carriage").entries
            .map { |key, value| "#{key}: #{value}" }.join(", ")
          "The Mandatory Charge with '#{config_string}' cannot be found."
        end

        def required_key
          "mandatory_charge_id"
        end
      end
    end
  end
end
