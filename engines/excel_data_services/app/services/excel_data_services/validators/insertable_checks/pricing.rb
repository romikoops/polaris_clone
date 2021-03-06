# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class Pricing < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_all_data(rows_data)
          check_ranges_overlapping_effective_period(rows_data)
        end

        def check_ranges_overlapping_effective_period(rows_data)
          grouping_keys = ExcelDataServices::Restructurers::Base::ROWS_BY_PRICING_PARAMS_GROUPING_KEYS -
            %i[effective_date expiration_date]
          grouped_data = rows_data.group_by { |row_data| row_data.slice(grouping_keys) }.values

          grouped_data.each do |group|
            rows_data_with_ranges = group.select { |row_data| row_data[:range].present? }
            rows_data_with_ranges_uniq_by_effective_period =
              rows_data_with_ranges.uniq { |row_data| [row_data[:effective_date], row_data[:expiration_date]] }

            next unless rows_data_with_ranges_uniq_by_effective_period.size > 1

            rows_data_with_ranges_uniq_by_effective_period.each do |row_data|
              add_to_errors(
                type: :error,
                row_nr: row_data[:row_nr],
                sheet_name: sheet_name,
                reason: "Rows that are connected by a range must have the same effective / expiration dates.",
                exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
              )
            end
          end
        end

        def check_single_data(row)
          check_group(row)
          check_correct_individual_effective_period(row)
          origin_hub_with_info = find_hub_by_name_or_locode_with_info(
            name: row.origin,
            country: row.origin_country,
            mot: row.mot,
            locode: row.origin_locode,
            terminal: row.origin_terminal
          )
          destination_hub_with_info = find_hub_by_name_or_locode_with_info(
            name: row.destination,
            country: row.destination_country,
            mot: row.mot,
            locode: row.destination_locode,
            terminal: row.destination_terminal
          )
          origin_hub = origin_hub_with_info[:hub]
          destination_hub = destination_hub_with_info[:hub]

          check_hub_existence(origin_hub_with_info, row)
          check_hub_existence(destination_hub_with_info, row)
          check_rate_basis(row)

          return unless origin_hub && destination_hub

          itinerary = Legacy::Itinerary.find_by(
            origin_hub: origin_hub,
            destination_hub: destination_hub,
            transshipment: row.transshipment,
            mode_of_transport: row.mot,
            organization: organization
          )

          check_overlapping_effective_periods(row, itinerary)
        end

        def check_rate_basis(row)
          rate_basis = row.rate_basis.upcase
          return if ::Pricings::RateBasis.exists?(internal_code: rate_basis) || VALID_RATE_BASES.include?(rate_basis)

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "\"#{rate_basis}\" is not a valid Rate Basis.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_overlapping_effective_periods(row, itinerary)
          return if itinerary.nil?

          pricings = itinerary.rates
            .where(tenant_vehicle: find_tenant_vehicle(row))
            .for_cargo_classes([row.load_type])
            .for_dates(row.effective_date, row.expiration_date)

          pricings.each do |old_pricing|
            overlap_checker = DateOverlapChecker.new(old_pricing, row)
            checker_that_hits = overlap_checker.perform
            next if checker_that_hits == "no_overlap"

            add_to_errors(
              type: :warning,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "There exist rates (in the system or this file) with an overlapping effective period.\n" \
                      "(#{checker_that_hits.humanize}: " \
                      "[#{overlap_checker.old_effective_period}] <-> [#{overlap_checker.new_effective_period}]).",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end

        def find_tenant_vehicle(row)
          carrier = Legacy::Carrier.find_by(name: row.carrier) if row.carrier.present?

          Legacy::TenantVehicle.find_by(
            organization: organization,
            name: row.service_level,
            mode_of_transport: row.mot,
            carrier: carrier
          )
        end
      end
    end
  end
end
