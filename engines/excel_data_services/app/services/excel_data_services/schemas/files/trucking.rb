# frozen_string_literal: true

# The Schemas::File class takes and xlsx and sees if it matches the required Schema::Sheet classes to be readable

module ExcelDataServices
  module Schemas
    module Files
      class Trucking < ExcelDataServices::Schemas::Files::Base
        def valid?
          [
            zone_schema,
            fee_schema,
            rate_schemas
          ].all?(&:present?)
        end

        def zone_schema
          @zone_schema ||= single_sheet(sheet_class: ExcelDataServices::Schemas::Sheet::TruckingZones)
        end

        def fee_schema
          @fee_schema ||= single_sheet(sheet_class: ExcelDataServices::Schemas::Sheet::TruckingFees)
        end

        def rate_schemas
          @rate_schemas ||= multiple_sheets(sheet_class: ExcelDataServices::Schemas::Sheet::TruckingRates)
        end
      end
    end
  end
end
