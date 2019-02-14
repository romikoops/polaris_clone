# frozen_string_literal: true

module ExcelDataServices
  module Loader
    class Uploader < Base
      POTENTIALLY_PERFORMING_METHODS = %i(
        validate_syntax
        restructure_data!
        validate_insertability
        validate_smart_assumptions
        validate_booking_possible
      ).freeze

      def initialize(tenant:, specific_identifier:, file_or_path:)
        super(tenant: tenant, specific_identifier: specific_identifier)
        @file_or_path = file_or_path
        @data = nil
      end

      def perform
        parse_and_sanitize_data!

<<<<<<< HEAD
        OPTIONALLY_PERFORMING_METHOD_NAMES.each do |method_name|
          optionally_execute(method_name)
        rescue ExcelDataServices::DataValidator::ValidationError => exception
=======
        performing_methods(klass_identifier).each do |method_name|
          send(method_name)
        rescue ExcelDataServices::DataValidator::ValidationError::ErrorLog => exception
>>>>>>> 9ef40f8ed... IMC-1207 simplify uploader
          return { has_errors: true, errors: exception.errors_ary }
        end

        insertion_stats = insert_into_database
        insertion_stats
      end

      private

      attr_reader :tenant, :klass_identifier, :file_or_path, :data

      def performing_methods(klass_identifier)
        do_not_execute_methods =
          case klass_identifier
          when 'Pricing'
            %i(validate_booking_possible)
          when 'LocalCharges'
            %i(validate_booking_possible)
          when 'ChargeCategories'
            %i(validate_smart_assumptions
               validate_booking_possible)
          end

        POTENTIALLY_PERFORMING_METHODS - do_not_execute_methods
      end

      def options
        @options ||= { tenant: tenant, data: data, klass_identifier: klass_identifier }
      end

      def parse_and_sanitize_data!
        file_parser = ExcelDataServices::FileParser.get(klass_identifier)
        @data = file_parser.parse(tenant: tenant, file_or_path: file_or_path)
      end

      def validate_syntax
        validate('Syntax')
      end

      def restructure_data!
        restructurer = ExcelDataServices::DataRestructurer.get(klass_identifier)
        @data = restructurer.restructure_data(options)
      end

      def validate_insertability
        validate('Insertability')
      end

      def validate_smart_assumptions
        validate('Smart Assumptions')
      end

      def validate_booking_possible
        validate('Booking Possible')
      end

      def validate(flavor)
        validator = ExcelDataServices::DataValidator.get(flavor, klass_identifier)
        errors = validator.validate(options)
        raise ValidationError.new(errors), "#{validator.class} caught #{errors.count} error(s)." unless errors.empty?
      end

      def insert_into_database
        inserter = ExcelDataServices::DatabaseInserter.get(klass_identifier)
        inserter.insert(options)
      end
    end
  end
end
