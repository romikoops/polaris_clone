# frozen_string_literal: true

module ExcelDataServices
  module Loader
    class Base
      def initialize(tenant:, specific_identifier:)
        @tenant = tenant
        @klass_identifier = determine_klass_identifier(specific_identifier)
      end

      def perform
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      private

      def determine_klass_identifier(specific_klass_identifier)
        case specific_klass_identifier
        when /(Ocean|Air).*/
          'Pricing'
        when /LocalCharges.*/
          'LocalCharges'
        when /ChargeCategories.*/
          'ChargeCategories'
        end
      end
    end
  end
end
