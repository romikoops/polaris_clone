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
          @zone_schema ||= file.sheets.each do |sheet_name|
            schema = ExcelDataServices::Schemas::Sheet::TruckingZones.new(file: file, sheet_name: sheet_name)
            return schema if schema.valid?
          end
        end

        def fee_schema
          @fee_schema ||= file.sheets.each do |sheet_name|
            schema = ExcelDataServices::Schemas::Sheet::TruckingFees.new(file: file, sheet_name: sheet_name)
            return schema if schema.valid?
          end
        end

        def rate_schemas
          @rate_schemas ||= begin
            file.sheets.each_with_object([]) do |sheet_name, schemas|
              schema = ExcelDataServices::Schemas::Sheet::TruckingRates.new(
                file: file, sheet_name: sheet_name
              )
              schemas << schema if schema.valid?
            end
          end
        end
      end
    end
  end
end
