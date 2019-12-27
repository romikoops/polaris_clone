# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module MissingValues
      class LocalCharges < ExcelDataServices::Validators::MissingValues::Base
        VALID_RATE_BASES = %w[
          PER_SHIPMENT
          PER_CONTAINER
          PER_BILL
          PER_CBM
          PER_KG
          PER_TON
          PER_WM
          PER_ITEM
          PER_CBM_TON
          PER_SHIPMENT_CONTAINER
          PER_BILL_CONTAINER
          PER_CBM_KG
          PER_KG_RANGE
          PER_WM_RANGE
          PER_X_KG_FLAT
          PER_UNIT_TON_CBM_RANGE
          PER_SHIPMENT_TON
        ].freeze

        USER_FRIENDLY_FEE_COMP_LOOKUP = {
          key: 'FEE_CODE',
          currency: 'CURRENCY'
        }.freeze

        private

        def check_single_data(row)
          row.fees.values.each do |fee_hsh|
            fee_hsh = fee_hsh.with_indifferent_access
            check_fee_comps_except_rate_basis(row.nr, fee_hsh)
            check_rate_basis(row.nr, fee_hsh)
          end
        end

        def check_fee_comps_except_rate_basis(row_nr, fee_hsh)
          %i[key currency].each do |fee_comp_key|
            next if fee_hsh[fee_comp_key]

            add_to_errors(
              type: :error,
              row_nr: row_nr,
              sheet_name: sheet_name,
              reason: "Missing value for #{USER_FRIENDLY_FEE_COMP_LOOKUP[fee_comp_key]}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis
            )
          end
        end

        def check_rate_basis(row_nr, fee_hsh)
          rate_basis = RateBasis.get_internal_key(fee_hsh[:rate_basis]&.upcase)

          unless VALID_RATE_BASES.include?(rate_basis)
            add_to_errors(
              type: :error,
              row_nr: row_nr,
              sheet_name: sheet_name,
              reason: "The rate basis \"#{rate_basis}\" is unknown.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis
            )
          end

          return unless missing_fee_values_for_rate_basis?(rate_basis, fee_hsh)

          add_to_errors(
            type: :error,
            row_nr: row_nr,
            sheet_name: sheet_name,
            reason: "Missing value for #{rate_basis}.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis
          )
        end

        def missing_fee_values_for_rate_basis?(rate_basis, fee_hsh) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
          case rate_basis
          when 'PER_SHIPMENT'
            !fee_hsh[:value]
          when 'PER_CONTAINER'
            !fee_hsh[:value]
          when 'PER_BILL'
            !fee_hsh[:value]
          when 'PER_CBM'
            !fee_hsh[:value]
          when 'PER_KG'
            !fee_hsh[:value]
          when 'PER_TON'
            !fee_hsh[:ton]
          when 'PER_WM'
            !fee_hsh[:value]
          when 'PER_ITEM'
            !fee_hsh[:value]
          when 'PER_CBM_TON'
            !(fee_hsh[:ton] && fee_hsh[:cbm])
          when 'PER_SHIPMENT_CONTAINER'
            !(fee_hsh[:shipment] && fee_hsh[:container])
          when 'PER_BILL_CONTAINER'
            !(fee_hsh[:container] && fee_hsh[:bill])
          when 'PER_CBM_KG'
            !(fee_hsh[:kg] && fee_hsh[:cbm])
          when 'PER_KG_RANGE'
            !fee_hsh[:range]
          when 'PER_WM_RANGE'
            !fee_hsh[:value]
          when 'PER_X_KG_FLAT'
            !(fee_hsh[:value] && fee_hsh[:base])
          when 'PER_UNIT_TON_CBM_RANGE'
            !fee_hsh[:range]
          end
        end
      end
    end
  end
end
