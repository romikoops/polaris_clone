# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurers
    class InsertionTypeDetector
      SACO_SHIPPING_LOCAL_CHARGE_FEE_CODES = %w(
        thc
      ).freeze

      def self.detect(single_data, data_restructurer_name)
        case data_restructurer_name
        when 'saco_shipping'
          # TODO: The data in SACO_SHIPPING_LOCAL_CHARGE_FEE_CODES should probably live in the database
          if SACO_SHIPPING_LOCAL_CHARGE_FEE_CODES.include?(single_data[:fee_code].downcase)
            'LocalCharges'
          else
            'Pricing'
          end
        end
      end
    end
  end
end
