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
                reason: 'Rows that are connected by a range must have the same effective / expiration dates.',
                exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
              )
            end
          end
        end

        def check_single_data(row)
          check_correct_individual_effective_period(row)

          user = get_user(row)
          check_customer_email(row, user)

          origin_hub_with_info = find_hub_by_name_or_locode_with_info(
            raw_name: row.origin,
            mot: row.mot,
            locode: row.origin_locode
          )
          destination_hub_with_info = find_hub_by_name_or_locode_with_info(
            raw_name: row.destination,
            mot: row.mot,
            locode: row.destination_locode
          )
          origin_hub = origin_hub_with_info[:hub]
          destination_hub = destination_hub_with_info[:hub]

          check_hub_existence(origin_hub_with_info, row)
          check_hub_existence(destination_hub_with_info, row)

          return unless origin_hub && destination_hub

          itinerary = Itinerary.find_by(
            name: "#{origin_hub.nexus.name} - #{destination_hub.nexus.name}",
            mode_of_transport: row.mot,
            tenant: tenant
          )

          check_overlapping_effective_periods(row, user, itinerary)
        end

        def get_user(row)
          User.find_by(tenant: tenant, email: row.customer_email&.downcase)
        end

        def check_customer_email(row, user)
          customer_unknown = row.customer_email.present? && user.nil?

          if customer_unknown # rubocop:disable Style/GuardClause
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "A user with email \"#{row.customer_email}\" does not exist.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end

        def check_overlapping_effective_periods(row, user, itinerary)
          return if itinerary.nil?

          pricings = itinerary.pricings
                              .where(user: user, tenant_vehicle: find_tenant_vehicle(row))
                              .for_cargo_classes([row.load_type])
                              .for_dates(row.effective_date, row.expiration_date)

          pricings.each do |old_pricing|
            overlap_checker = DateOverlapChecker.new(old_pricing, row)
            checker_that_hits = overlap_checker.perform
            next if checker_that_hits == 'no_overlap'

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
          carrier = Carrier.find_by(name: row.carrier) if row.carrier.present?

          TenantVehicle.find_by(
            tenant: tenant,
            name: row.service_level,
            mode_of_transport: row.mot,
            carrier: carrier
          )
        end
      end
    end
  end
end
