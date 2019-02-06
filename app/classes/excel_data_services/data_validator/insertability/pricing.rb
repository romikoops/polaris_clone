# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class Pricing
        def self.validate(options)
          new(options).perform
        end

        def initialize(data:, tenant:)
          @data = data
          @tenant = tenant
          @errors = []
        end

        def perform
          data.each do |_sheet_name, sheet_data|
            sheet_data[:rows_data].each_with_index do |row_data, i|
              row = ExcelDataServices::Row.new(row_data: row_data, tenant: tenant)

              itinerary_in_current_row = row.itinerary
              next if itinerary_in_current_row.nil?

              row.cargo_classes.each do |cargo_class|
                tenant_vehicle_in_current_row = row.tenant_vehicle
                pricings = itinerary_in_current_row.pricings
                                    .where(user: row.user, tenant_vehicle: tenant_vehicle_in_current_row)
                                    .for_cargo_class(cargo_class)
                                    .for_dates(row.effective_date, row.expiration_date)
                next if pricings.reject { |pricing| pricing.uuid == row.uuid }.empty?

                @errors << {
                  row_nr: i + 1,
                  reason: 'Overlapping Dates'
                }
              end
            end
          end
          errors
        end

        private

        attr_reader :data, :tenant, :errors
      end
    end
  end
end
