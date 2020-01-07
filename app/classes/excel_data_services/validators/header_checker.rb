# frozen_string_literal: true

module ExcelDataServices
  module Validators
    class HeaderChecker < ExcelDataServices::Validators::Base
      HEADER_DIFF_THRESHOLD = 0.14

      module StaticHeadersForRestructurers
        # The names of the constants here must exactly match the names of the data restructurers (upcased).

        LOCAL_CHARGES = %i[
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
        ].freeze

        PRICING_DYNAMIC_FEE_COLS_NO_RANGES = %i[
          effective_date
          expiration_date
          customer_email
          origin
          country_origin
          destination
          country_destination
          mot
          carrier
          service_level
          load_type
          rate_basis
          transit_time
          currency
        ].freeze

        PRICING_ONE_COL_FEE_AND_RANGES = %i[
          effective_date
          expiration_date
          customer_email
          origin
          country_origin
          destination
          country_destination
          mot
          carrier
          service_level
          load_type
          rate_basis
          range_min
          range_max
          fee_code
          fee_name
          currency
          fee_min
          fee
        ].freeze

        SACO_SHIPPING = %i[
          internal
          destination_country
          destination_locode
          destination_hub
          terminal
          transshipment_via
          carrier
          origin_locode
          effective_date
          expiration_date
        ].freeze

        MARGINS = %i[
          effective_date
          expiration_date
          origin
          country_origin
          destination
          country_destination
          mot
          carrier
          service_level
          margin_type
          load_type
          fee_code
          operator
          margin
        ].freeze

        SCHEDULE_GENERATOR = %i[
          origin
          destination
          carrier
          service_level
          etd_days
          transit_time
          cargo_class
        ].freeze

        CHARGE_CATEGORIES = %i[
          internal_code
          fee_code
          fee_name
        ].freeze

        COMPANIES = %i[
          name
          email
          phone
          vat_number
          external_id
          address
        ].freeze

        EMPLOYEES = %i[
          company_name
          first_name
          last_name
          email
          password
          phone
          vat_number
          external_id
          address
        ].freeze

        NOTES = %i[
          country
          unlocode
          note
        ].freeze

        HUBS = %i[
          status
          type
          name
          locode
          latitude
          longitude
          country
          full_address
          photo
          free_out
          import_charges
          export_charges
          pre_carriage
          on_carriage
          alternative_names
        ].freeze
      end

      attr_reader :data_restructurer_name, :errors

      def initialize(sheet_name, parsed_headers)
        @sheet_name = sheet_name
        @parsed_headers = parsed_headers
        @data_restructurer_name = nil
        @errors_and_warnings = []
      end

      def perform
        result = determine_data_restructurer_name_and_headers

        return unless result

        correct_headers = result[:correct_headers]
        diff = result[:diff]
        unrecognized = result[:unrecognized]

        if diff.present? # rubocop:disable Style/GuardClause
          add_to_errors(
            type: :error,
            row_nr: 1,
            sheet_name: sheet_name,
            reason: "The following headers of sheet \"#{sheet_name}\" are not valid:\n" \
                    "Correct static headers for this sheet are: \"#{correct_headers.map(&:upcase).join(', ')}\",\n" \
                    "Missing static headers are               : \"#{diff.map(&:upcase).join(', ')}\",\n" \
                    "Unrecognized static headers are          : \"#{unrecognized.map(&:upcase).join(', ')}\"",
            exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker
          )
        end
      end

      private

      attr_reader :sheet_name, :parsed_headers

      def determine_data_restructurer_name_and_headers
        data_restructurer_names.each do |restructurer_name|
          static_headers = headers_from_data_restructurer_name(restructurer_name)
          static_size = static_headers.size
          parsed_static_part = parsed_headers.slice(0, static_size)
          diff = static_headers - parsed_static_part
          unrecognized = parsed_static_part - static_headers

          next unless diff_below_threshold?(diff.size, static_size)

          @data_restructurer_name = restructurer_name
          return { correct_headers: static_headers,
                   diff: diff,
                   unrecognized: unrecognized }
        end

        add_to_errors(
          type: :error,
          row_nr: 1,
          sheet_name: sheet_name,
          reason: 'The type of the data sheet could not be determined. ' \
                  'Please check if the headers of the sheet are correct.',
          exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker
        )

        nil
      end

      def diff_below_threshold?(diff_size, correct_size)
        diff_size.to_f / correct_size < HEADER_DIFF_THRESHOLD
      end

      def data_restructurer_names
        self.class::StaticHeadersForRestructurers.constants(false).map { |constant| constant.to_s.downcase }
      end

      def headers_from_data_restructurer_name(restructurer_name)
        "#{self.class}::StaticHeadersForRestructurers::#{restructurer_name.upcase}".constantize
      end
    end
  end
end
