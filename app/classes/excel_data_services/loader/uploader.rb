# frozen_string_literal: true

module ExcelDataServices
  module Loader
    class Uploader < Base
      def initialize(tenant:, specific_identifier:, file_or_path:)
        super(tenant: tenant, specific_identifier: specific_identifier)
        @file_or_path = file_or_path
        @data = nil
      end

      def perform
        @data = parse_and_sanitize_data
        validate_format
        @data = restructure_data
        validate_insertability
        validate_smart_assumptions
        validate_booking_possible
        insertion_stats = insert_into_database
        insertion_stats
      rescue ExcelDataServices::DataValidator::ValidationError::ErrorLog => exception
        { has_errors: true, errors: exception.errors_ary }
      end

      private

      attr_reader :tenant, :klass_identifier, :file_or_path, :data

      def options
        { tenant: tenant, data: data, klass_identifier: klass_identifier }
      end

      def parse_and_sanitize_data
        file_parser = ExcelDataServices::FileParser.get(klass_identifier)
        file_parser.parse(tenant: tenant, file_or_path: file_or_path)
      end

      def validate_format
        validate('Format')
      end

      def restructure_data
        restructurer = ExcelDataServices::DataRestructurer.get(klass_identifier)
        restructurer.restructure_data(options)
      end

      def validate_insertability
        validate('Insertability')
      end

      def validate_smart_assumptions
        validate('Smart Assumptions')
      end

      def validate_booking_possible
        # TODO
        # validate('Booking Possible')
      end

      def validate(flavor)
        validator = ExcelDataServices::DataValidator.get(flavor, klass_identifier)
        errors = validator.validate(options)
        if errors.present? # rubocop:disable Style/GuardClause
          raise ExcelDataServices::DataValidator::ValidationError::ErrorLog.new(errors),
                "#{validator.class} caught #{errors.count} error(s)."
        end
      end

      def insert_into_database
        inserter = ExcelDataServices::DatabaseInserter.get(klass_identifier)
        inserter.insert(options)
      end
    end
  end
end
