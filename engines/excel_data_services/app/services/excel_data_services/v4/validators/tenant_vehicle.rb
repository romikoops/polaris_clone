# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class TenantVehicle < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::TenantVehicle.state(state: state)
        end

        def error_reason(row:)
          "The service '#{row['service']} (#{row['carrier']})' cannot be found."
        end
      end
    end
  end
end
