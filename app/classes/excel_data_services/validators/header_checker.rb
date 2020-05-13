# frozen_string_literal: true

module ExcelDataServices
  module Validators
    class HeaderChecker < ExcelDataServices::Validators::Base
      THRESHOLD_MATCHING_HEADERS = 0.86

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

        OPTIONAL_LOCAL_CHARGES = %i[
          group_id
          group_name
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
          currency
        ].freeze

        OPTIONAL_PRICING_DYNAMIC_FEE_COLS_NO_RANGES = %i[
          origin_locode
          destination_locode
          group_id
          group_name
          transshipment
          transit_time
        ].freeze

        PRICING_ONE_FEE_COL_AND_RANGES = %i[
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

        OPTIONAL_PRICING_ONE_FEE_COL_AND_RANGES = %i[
          origin_locode
          destination_locode
          group_id
          group_name
          transshipment
          transit_time
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
          mot
          transit_time
          cargo_class
        ].freeze

        OPTIONAL_SCHEDULE_GENERATOR = %i[
          transshipment
        ].freeze

        SCHEDULES = %i[
          from
          to
          closing_date
          etd
          eta
          transit_time
          service_level
          carrier
          mode_of_transport
          vessel
          voyage_code
          load_type
        ].freeze

        OPTIONAL_SCHEDULES = %i[
          transshipment
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

        MAX_DIMENSIONS = %i[
          carrier
          service_level
          mode_of_transport
          payload_in_kg
          chargeable_weight
          aggregate
          load_type
        ].freeze
      end

      OPTIONAL_MAX_DIMENSIONS = %i[
        origin_locode
        destination_locode
        width
        length
        height
        dimension_x
        dimension_y
        dimension_z
      ].freeze

      attr_reader :restructurer_name, :errors

      def initialize(sheet_name, parsed_headers)
        @sheet_name = sheet_name
        @parsed_headers = parsed_headers
        @restructurer_name = nil
        @errors_and_warnings = []
      end

      def perform
        @restructurer_name = restructurer_with_largest_overlap
        mandatory_headers = headers_for_restructurer(restructurer_name: restructurer_name, header_type: :mandatory)
        matching_headers = mandatory_headers & parsed_headers
        missing_headers = mandatory_headers - matching_headers
        if below_threshold?(matching_size: matching_headers.size, mandatory_size: mandatory_headers.size)
          add_to_errors(
            type: :error,
            row_nr: 1,
            sheet_name: sheet_name,
            reason: 'The type of the data sheet could not be determined. Please check if the column names are correct.',
            exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker
          )

          @restructurer_name = nil

          return
        end

        return if missing_headers.empty?

        add_to_errors(
          type: :error,
          row_nr: 1,
          sheet_name: sheet_name,
          reason: "The following headers of sheet \"#{sheet_name}\" are not valid:\n" \
                  "Correct static headers for this sheet are: \"#{stringify(matching_headers)}\",\n" \
                  "Missing static headers are               : \"#{stringify(missing_headers)}\"",
          exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker
        )
      end

      private

      attr_reader :sheet_name, :parsed_headers

      def restructurer_with_largest_overlap
        restructurer_names.min_by do |restructurer_name|
          correct_headers = all_headers_for_restructurer(restructurer_name: restructurer_name)

          if parsed_headers.size >= correct_headers.size
            (parsed_headers - correct_headers).size
          else
            (correct_headers - parsed_headers).size
          end
        end
      end

      def restructurer_names
        names = self.class::StaticHeadersForRestructurers.constants(false).each_with_object([]) do |constant, constants|
          name = constant.to_s.downcase
          constants << name unless name.starts_with?('optional')
        end

        names -= ['pricing_one_fee_col_and_ranges'] unless parsed_headers.include?(:fee_code)
        names
      end

      def all_headers_for_restructurer(restructurer_name:)
        headers_for_restructurer(restructurer_name: restructurer_name, header_type: :mandatory) +
          headers_for_restructurer(restructurer_name: restructurer_name, header_type: :optional)
      end

      def headers_for_restructurer(restructurer_name:, header_type:)
        name_part = { mandatory: '', optional: 'OPTIONAL_' }[header_type]
        const_name = name_part + restructurer_name.upcase
        const_module = self.class::StaticHeadersForRestructurers
        const_module.const_defined?(const_name) ? const_module.const_get(const_name) : []
      end

      def below_threshold?(mandatory_size:, matching_size:)
        matching_size / mandatory_size.to_f < THRESHOLD_MATCHING_HEADERS
      end

      def stringify(headers)
        headers.join(', ').upcase
      end
    end
  end
end
