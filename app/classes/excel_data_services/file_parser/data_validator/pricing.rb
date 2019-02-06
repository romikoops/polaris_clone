# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    module DataValidator
      class Pricing
        def self.validate_data(data, tenant)
          errors = []

          data.each do |_sheet_name, sheet_data|
            sheet_data[:rows_data].each_with_index do |row_data, i|
              row_data[:row_no] = i + 1
              itinerary = get_itinerary(row_data, tenant)
              next if itinerary.nil?

              cargo_classes(row_data).each do |cargo_class|
                pricing_tenant_vehicle = tenant_vehicle(row_data, tenant)
                pricings = itinerary.pricings
                                    .for_cargo_class(cargo_class)
                                    .where(user: user(row_data), tenant_vehicle: pricing_tenant_vehicle)
                                    .for_dates(row_data[:effective_date], row_data[:expiration_date])
                next if pricings.reject { |pricing| pricing.uuid == row_data[:uuid] }.empty?

                errors << {
                  row_no: row_data[:row_no],
                  reason: 'Overlapping Dates'
                }
              end
            end
          end
          errors
        end

        def self.get_itinerary(row_data, tenant)
          Itinerary.find_by(name: itinerary_name(row_data), tenant: tenant)
        end

        def self.itinerary_name(row_data)
          [row_data[:origin], row_data[:destination]].join(' - ')
        end

        def self.tenant_vehicle(row_data, tenant)
          TenantVehicle.find_by(
            tenant: tenant,
            name: row_data[:service_level],
            carrier: carrier(row_data),
            mode_of_transport: row_data[:mot]
          )
        end

        def self.carrier(row_data)
          Carrier.find_by_name(row_data[:carrier]) unless row_data[:carrier].blank?
        end

        def self.cargo_classes(row_data)
          if row_data[:load_type].casecmp('fcl').zero?
            %w(fcl_20 fcl_40 fcl_40_hq)
          else
            [row_data[:load_type].downcase]
          end
        end

        def self.user(row_data)
          User.find_by(tenant: @tenant, email: row_data[:customer_email]) if row_data[:customer_email].present?
        end
      end
    end
  end
end
