# frozen_string_literal: true

module ExcelDataServices
  module Validators
    class HeaderChecker < ExcelDataServices::Validators::Base
      THRESHOLD_MATCHING_HEADERS = 0.86

      module StaticHeadersForRestructurers
        # The names of the constants here must exactly match the names of the data restructurers (upcased).

        LOCAL_CHARGES = {
          group_id: :optional,
          group_name: :optional,
          effective_date: :required,
          expiration_date: :required,
          locode: :optional,
          hub: :optional,
          country: :optional,
          counterpart_locode: :optional,
          counterpart_hub: :optional,
          counterpart_country: :optional,
          service_level: :required,
          carrier: :required,
          fee_code: :required,
          fee: :required,
          mot: :required,
          load_type: :required,
          direction: :required,
          currency: :required,
          rate_basis: :required,
          minimum: :required,
          maximum: :required,
          base: :required,
          ton: :required,
          cbm: :required,
          kg: :required,
          item: :required,
          shipment: :required,
          bill: :required,
          container: :required,
          wm: :required,
          range_min: :required,
          range_max: :required,
          dangerous: :required
        }.freeze

        PRICING_DYNAMIC_FEE_COLS_NO_RANGES = {
          group_id: :optional,
          group_name: :optional,
          effective_date: :required,
          expiration_date: :required,
          origin_locode: :optional,
          origin: :optional,
          country_origin: :optional,
          destination_locode: :optional,
          destination: :optional,
          country_destination: :optional,
          mot: :required,
          carrier: :required,
          service_level: :required,
          load_type: :required,
          rate_basis: :required,
          transshipment: :optional,
          transit_time: :optional,
          remarks: :optional,
          wm_ratio: :optional,
          vm_ratio: :optional,
          currency: :required
        }.freeze

        PRICING_ONE_FEE_COL_AND_RANGES = {
          group_id: :optional,
          group_name: :optional,
          effective_date: :required,
          expiration_date: :required,
          origin_locode: :optional,
          origin: :optional,
          country_origin: :optional,
          destination_locode: :optional,
          destination: :optional,
          country_destination: :optional,
          mot: :required,
          carrier: :required,
          service_level: :required,
          load_type: :required,
          rate_basis: :required,
          transshipment: :optional,
          transit_time: :optional,
          remarks: :optional,
          wm_ratio: :optional,
          vm_ratio: :optional,
          fee_code: :required,
          fee_name: :required,
          currency: :required,
          fee_min: :required,
          fee: :required,
          range_min: :required,
          range_max: :required
        }.freeze

        SACO_SHIPPING = {
          internal: :required,
          destination_country: :required,
          destination_locode: :required,
          destination_hub: :required,
          terminal: :required,
          transshipment_via: :required,
          carrier: :required,
          origin_locode: :required,
          effective_date: :required,
          expiration_date: :required
        }.freeze

        MARGINS = {
          effective_date: :required,
          expiration_date: :required,
          origin: :required,
          country_origin: :required,
          destination: :required,
          country_destination: :required,
          mot: :required,
          carrier: :required,
          service_level: :required,
          margin_type: :required,
          load_type: :required,
          fee_code: :required,
          operator: :required,
          margin: :required
        }.freeze

        SCHEDULE_GENERATOR = {
          origin: :required,
          destination: :required,
          carrier: :required,
          service_level: :required,
          etd_days: :required,
          mot: :required,
          transit_time: :required,
          cargo_class: :required,
          transshipment: :optional
        }.freeze

        SCHEDULES = {
          from: :required,
          to: :required,
          closing_date: :required,
          etd: :required,
          eta: :required,
          transit_time: :required,
          service_level: :required,
          carrier: :required,
          mode_of_transport: :required,
          vessel: :required,
          voyage_code: :required,
          load_type: :required,
          transshipment: :optional
        }.freeze

        CHARGE_CATEGORIES = {
          fee_code: :required,
          fee_name: :required,
          internal_code: :required
        }.freeze

        COMPANIES = {
          name: :required,
          email: :required,
          phone: :required,
          vat_number: :required,
          external_id: :required,
          address: :required,
          payment_terms: :optional
        }.freeze

        EMPLOYEES = {
          company_name: :required,
          first_name: :required,
          last_name: :required,
          email: :required,
          password: :required,
          phone: :required,
          vat_number: :required,
          external_id: :required,
          address: :required
        }.freeze

        NOTES = {
          country: :required,
          unlocode: :required,
          note: :required
        }.freeze

        HUBS = {
          status: :required,
          type: :required,
          name: :required,
          locode: :required,
          terminal: :optional,
          terminal_code: :optional,
          latitude: :required,
          longitude: :required,
          country: :required,
          full_address: :required,
          free_out: :required,
          import_charges: :required,
          export_charges: :required,
          pre_carriage: :required,
          on_carriage: :required,
          alternative_names: :required
        }.freeze

        MAX_DIMENSIONS = {
          origin_locode: :optional,
          destination_locode: :optional,
          carrier: :required,
          service_level: :required,
          mode_of_transport: :required,
          payload_in_kg: :required,
          chargeable_weight: :required,
          aggregate: :required,
          load_type: :required,
          width: :optional,
          length: :optional,
          height: :optional,
          dimension_x: :optional,
          dimension_y: :optional,
          dimension_z: :optional
        }.freeze
      end

      attr_reader :restructurer_name, :errors

      def initialize(sheet_name, parsed_headers)
        @sheet_name = sheet_name
        @parsed_headers = parsed_headers
        @restructurer_name = nil
        @errors_and_warnings = []
      end

      def perform
        @restructurer_name = restructurer_with_largest_overlap
        mandatory_headers = headers_for_restructurer(restructurer_name: restructurer_name, header_type: :required)
        matching_headers = mandatory_headers & parsed_headers
        missing_headers = mandatory_headers - matching_headers
        if below_threshold?(matching_size: matching_headers.size, mandatory_size: mandatory_headers.size)
          add_to_errors(
            type: :error,
            row_nr: 1,
            sheet_name: sheet_name,
            reason: "The type of the data sheet could not be determined. Please check if the column names are correct.",
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
        names = self.class::StaticHeadersForRestructurers.constants(false).each_with_object([]) { |constant, constants|
          name = constant.to_s.downcase
          constants << name unless name.starts_with?("optional")
        }

        names -= ["pricing_one_fee_col_and_ranges"] unless parsed_headers.include?(:fee_code)
        names
      end

      def all_headers_for_restructurer(restructurer_name:)
        headers_for_restructurer(restructurer_name: restructurer_name, header_type: :required) +
          headers_for_restructurer(restructurer_name: restructurer_name, header_type: :optional)
      end

      def headers_for_restructurer(restructurer_name:, header_type:)
        const_name = restructurer_name.upcase
        const_module = self.class::StaticHeadersForRestructurers
        headers = const_module.const_defined?(const_name) ? const_module.const_get(const_name) : {}
        headers.keys.select { |key| headers[key] == header_type }
      end

      def below_threshold?(mandatory_size:, matching_size:)
        matching_size / mandatory_size.to_f < THRESHOLD_MATCHING_HEADERS
      end

      def stringify(headers)
        headers.join(", ").upcase
      end
    end
  end
end
