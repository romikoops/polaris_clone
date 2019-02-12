# frozen_string_literal: true

module ExcelDataServices
  module Row
    class Base
      def initialize(row_data:, tenant:)
        @data = row_data
        @tenant = tenant
      end

      def [](key)
        data[key.to_sym]
      end

      def nr
        @nr ||= data[:row_nr]
      end

      def currency
        @currency ||= data[:currency]
      end

      def customer_email
        @customer_email ||= data[:customer_email]
      end

      def data_extraction_method
        @data_extraction_method ||= data[:data_extraction_method]
      end

      def carrier
        @carrier ||= data[:carrier]
      end

      def effective_date
        @effective_date ||= data[:effective_date]
      end

      def expiration_date
        @expiration_date ||= data[:expiration_date]
      end

      def fee_code
        @fee_code ||= data[:fee_code]
      end

      def fee_name
        @fee_name ||= data[:fee_name]
      end

      def fee
        @fee ||= data[:fee]
      end

      def fee_min
        @fee_min ||= data[:fee_min]
      end

      def load_type
        @load_type ||= data[:load_type]
      end

      def mot
        @mot ||= data[:mot]
      end

      def range
        @range ||= data[:range]
      end

      def rate_basis
        @rate_basis ||= data[:rate_basis]
      end

      def service_level
        @service_level ||= data[:service_level] || 'standard'
      end

      def uuid
        @uuid ||= data[:uuid]
      end

      private

      attr_reader :data, :tenant
    end
  end
end
