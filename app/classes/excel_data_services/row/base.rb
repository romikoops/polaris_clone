# frozen_string_literal: true

module ExcelDataServices
  module Row
    class Base
      def initialize(row_data:, tenant:)
        @data = row_data
        @tenant = tenant
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

      def specific_charge_params_for_reading
        rate_basis_retrieved = RateBasis.get_internal_key(rate_basis.upcase)
        @specific_charge_params_for_reading ||=
          case rate_basis_retrieved
          when 'PER_SHIPMENT'
            { value: data[:shipment] }
          when 'PER_CONTAINER'
            { value: data[:container] }
          when 'PER_BILL'
            { value: data[:bill] }
          when 'PER_CBM'
            { value: data[:cbm] }
          when 'PER_KG'
            { value: data[:kg] }
          when 'PER_TON'
            { ton: data[:ton] }
          when 'PER_WM'
            { value: data[:wm] }
          when 'PER_ITEM'
            { value: data[:item] }
          when 'PER_CBM_TON'
            { ton: data[:ton], cbm: data[:cbm] }
          when 'PER_SHIPMENT_CONTAINER'
            { shipment: data[:shipment], container: data[:container] }
          when 'PER_BILL_CONTAINER'
            { container: data[:container], bill: data[:bill] }
          when 'PER_CBM_KG'
            { kg: data[:kg], cbm: data[:cbm] }
          when 'PER_KG_RANGE'
            { range_min: data[:range_min], range_max: data[:range_max], kg: data[:kg] }
          when 'PER_WM_RANGE'
            { range_min: data[:range_min], range_max: data[:range_max], wm: data[:wm] }
          when 'PER_X_KG_FLAT'
            { value: data[:kg], base: data[:base] }
          when 'PER_UNIT_TON_CBM_RANGE'
            { cbm: data[:cbm],
              ton: data[:ton],
              range_min: data[:range_min],
              range_max: data[:range_max] }
          end
      end

      private

      attr_reader :data, :tenant
    end
  end
end
