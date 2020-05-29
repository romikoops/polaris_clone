# frozen_string_literal: true

module ExcelDataServices
  module Validators
    class Base < ExcelDataServices::Base
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
        PER_KG_RANGE_FLAT
        PER_CBM_RANGE
        PER_CBM_RANGE_FLAT
        PER_WM_RANGE
        PER_WM_RANGE_FLAT
        PER_UNIT_RANGE
        PER_UNIT_RANGE_FLAT
        PER_X_KG_FLAT
        PER_UNIT_TON_CBM_RANGE
        PER_SHIPMENT_TON
      ].freeze

      def self.get(flavor, klass_identifier)
        "#{parent}::#{flavor.titleize.delete(' ')}::#{klass_identifier}".constantize
      end

      def initialize(tenant:, sheet_name:, data:, options: {})
        @tenant = tenant
        @tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant.id)
        @data = data
        @sheet_name = sheet_name
        @klass_identifier = self.class.name.split('::').last
        @errors_and_warnings = []
        @options = options
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def valid?
        results(filter: :error).empty?
      end

      def results(filter: nil)
        if filter
          errors_and_warnings.select { |error| error[:type] == filter }
        else
          errors_and_warnings
        end
      end

      def errors_and_warnings
        @errors_and_warnings.uniq
      end

      private

      attr_reader :tenant, :sheet_name, :data, :klass_identifier, :options

      def add_to_errors(type:, row_nr:, sheet_name:, reason:, exception_class:)
        @errors_and_warnings << { type: type,
                                  row_nr: row_nr,
                                  sheet_name: sheet_name,
                                  reason: reason,
                                  exception_class: exception_class }
      end
    end
  end
end
