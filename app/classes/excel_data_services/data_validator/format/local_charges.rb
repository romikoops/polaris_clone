# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Format
      class LocalCharges < ExcelDataServices::DataValidator::Format::Base
        include ExcelDataServices::LocalChargesTool

        VALID_STATIC_HEADERS = %i(
          uuid
          hub
          country
          effective_date
          expiration_date
          counterpart_hub
          counterpart_country
          service_level
          carrier
          fee_code
          fee
          mot
          load_type
          direction
          currency
          rate_basis
          minimum
          maximum
          base
          ton
          cbm
          kg
          item
          shipment
          bill
          container
          wm
          range_min
          range_max
          dangerous
        ).freeze

        VALID_RATE_BASISES = %w(
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
        ).freeze

        private

        def check_row(row)
          check_rate_basis(row)
          check_missing_values_for_rate_basis(row)
        end

        def build_valid_headers(_data_extraction_method)
          VALID_STATIC_HEADERS
        end

        def check_rate_basis(row)
          binding.pry if row.rate_basis.nil?
          rate_basis = RateBasis.get_internal_key(row.rate_basis.upcase)

          unless VALID_RATE_BASISES.include?(rate_basis)
            raise ExcelDataServices::DataValidator::ValidationError::Format::UnknownRateBasis,
                  "RATE_BASIS \"#{rate_basis}\" not found!"
          end

          true
        end

        def check_missing_values_for_rate_basis(row)
          charge_params_for_rate_basis =
            specific_charge_params_for_reading(row.rate_basis, row)

          unless charge_params_for_rate_basis.values.all?
            raise ExcelDataServices::DataValidator::ValidationError::Format::MissingValuesForRateBasis,
                  "Missing value for #{row.rate_basis}."
          end

          true
        end
      end
    end
  end
end
