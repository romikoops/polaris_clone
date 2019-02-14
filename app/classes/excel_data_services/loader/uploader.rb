# frozen_string_literal: true

module ExcelDataServices
  module Loader
    class Uploader < Base
      def initialize(tenant:, specific_identifier:, file_or_path:)
        super(tenant: tenant, specific_identifier: specific_identifier)
        @file_or_path = file_or_path
      end

      def perform # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        data = parse_and_sanitize

        errors = validate_syntax(data) if should_execute?(:validate_syntax)
        return { has_errors: true, errors: errors } unless errors.blank?

        data = restructure_data(data) if should_execute?(:restructure_data)

        errors = validate_insertability(data) if should_execute?(:validate_insertability)
        return { has_errors: true, errors: errors } unless errors.blank?

        errors = validate_smart_assumptions(data) if should_execute?(:validate_smart_assumptions)
        return { has_errors: true, errors: errors } unless errors.blank?

        insertion_stats = insert_into_database(data)

        validate_booking_possible(data) if should_execute?(:validate_booking_possible)

        insertion_stats
      end

      private

      attr_reader :tenant, :klass_identifier, :file_or_path, :should_execute_map

      def should_execute?(method_name)
        return should_execute_map[method_name] if should_execute_map

        method_names =
          %i(validate_syntax
             restructure_data
             validate_insertability
             validate_smart_assumptions
             validate_booking_possible)

        flags =
          case klass_identifier
          when 'Pricing'
            [true, true, true, true, true]
          when 'LocalCharges'
            [true, true, true, true, true]
          when 'ChargeCategories'
            [true, true, true, false, false]
          end

        @should_execute_map = method_names.zip(flags).to_h
        should_execute_map[method_name]
      end

      def parse_and_sanitize
        file_parser = ExcelDataServices::FileParser.get(klass_identifier)
        options = { tenant: tenant, file_or_path: file_or_path }
        file_parser.parse(options)
      end

      def validate_syntax(raw_sheets_data)
        syntax_validator = ExcelDataServices::DataValidator.get('Syntax', klass_identifier)
        options = { data: raw_sheets_data, tenant: tenant, klass_identifier: klass_identifier }
        syntax_validator.validate(options)
      end

      def restructure_data(raw_sheets_data)
        restructurer = ExcelDataServices::DataRestructurer.get(klass_identifier)
        options = { data: raw_sheets_data, tenant: tenant }
        restructurer.restructure_data(options)
      end

      def validate_insertability(restructured_sheets_data)
        insertability_validator = ExcelDataServices::DataValidator.get('Insertability', klass_identifier)
        options = { data: restructured_sheets_data, tenant: tenant, klass_identifier: klass_identifier }
        insertability_validator.validate(options)
      end

      def validate_smart_assumptions(restructured_sheets_data)
        smart_assumptions_validator = ExcelDataServices::DataValidator.get('Smart Assumptions', klass_identifier)
        options = { data: restructured_sheets_data, tenant: tenant, klass_identifier: klass_identifier }
        smart_assumptions_validator.validate(options)
      end

      def insert_into_database(restructured_sheets_data)
        inserter = ExcelDataServices::DatabaseInserter.get(klass_identifier)
        options = { tenant: tenant,
                    data: restructured_sheets_data,
                    klass_identifier: klass_identifier }
        inserter.insert(options)
      end

      def validate_booking_possible(_data)
        # TODO
      end
    end
  end
end
