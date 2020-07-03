# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Base
      def self.get(klass_identifier)
        "#{parent}::#{klass_identifier.titleize.delete(' ')}".constantize
      end

      def initialize(row_data:, organization:)
        @data = row_data
        @organization = organization
      end

      def [](key)
        key = key.to_sym
        respond_to?(key) ? send(key) : data[key]
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

      def carrier
        @carrier ||= data[:carrier]
      end

      def effective_date
        @effective_date ||= data[:effective_date].beginning_of_day
      end

      def expiration_date
        @expiration_date ||= data[:expiration_date].end_of_day.change(usec: 0)
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

      def sheet_name
        @sheet_name ||= data[:sheet_name]
      end

      def group_id
        @group_id ||= data[:group_id]
      end

      def group_name
        @group_name ||= data[:group_name]
      end

      def transshipment
        @transshipment ||= data[:transshipment] || data[:transshipment_via]
      end

      def origin
        @origin ||= data[:origin]
      end

      def destination
        @destination ||= data[:destination]
      end

      def mode_of_transport
        @mode_of_transport ||= data[:mode_of_transport]
      end

      def transit_time
        @transit_time ||= data[:transit_time]
      end

      def itinerary_name
        @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
      end

      def cargo_class
        @cargo_class ||= data[:cargo_class]
      end

      private

      attr_reader :data, :organization
    end
  end
end
