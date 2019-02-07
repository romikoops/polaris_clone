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

      def itinerary
        @itinerary ||= Itinerary.find_by(name: itinerary_name, tenant: tenant)
      end

      def itinerary_name
        @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
      end

      def cargo_classes
        @cargo_classes ||= if data[:load_type].casecmp('fcl').zero?
                             %w(fcl_20 fcl_40 fcl_40_hq)
                           else
                             [data[:load_type].downcase]
                           end
      end

      def tenant_vehicle
        @tenant_vehicle ||= TenantVehicle.find_by(
          tenant: tenant,
          name: data[:service_level],
          carrier: carrier,
          mode_of_transport: data[:mot]
        )
      end

      def carrier
        @carrier ||= Carrier.find_by_name(data[:carrier]) unless data[:carrier].blank?
      end

      def user
        @user ||= User.find_by(tenant: tenant, email: data[:customer_email]) if data[:customer_email].present?
      end

      def uuid
        @uuid ||= data[:uuid]
      end

      def effective_date
        @effective_date ||= data[:effective_date]
      end

      def expiration_date
        @expiration_date ||= data[:expiration_date]
      end

      def rate_basis
        @rate_basis ||= data[:rate_basis]
      end

      def specific_charge_params_for_reading
        rate_basis_retrieved = RateBasis.get_internal_key(rate_basis.upcase)
        @specific_charge_params_for_reading ||=
          case rate_basis_retrieved
          when 'PER_SHIPMENT' then { value: data[:shipment] }
          when 'PER_CONTAINER' then { value: data[:container] }
          when 'PER_BILL' then { value: data[:bill] }
          when 'PER_CBM' then { value: data[:cbm] }
          when 'PER_KG' then { value: data[:kg] }
          when 'PER_TON' then { ton: data[:ton] }
          when 'PER_WM' then { value: data[:wm] }
          when 'PER_ITEM' then { value: data[:item] }
          when 'PER_CBM_TON' then { ton: data[:ton], cbm: data[:cbm] }
          when 'PER_SHIPMENT_CONTAINER' then { shipment: data[:shipment], container: data[:container] }
          when 'PER_BILL_CONTAINER' then { container: data[:container], bill: data[:bill] }
          when 'PER_CBM_KG' then { kg: data[:kg], cbm: data[:cbm] }
          when 'PER_KG_RANGE' then { range_min: data[:range_min], range_max: data[:range_max], kg: data[:kg] }
          when 'PER_WM_RANGE' then { range_min: data[:range_min], range_max: data[:range_max], wm: data[:wm] }
          when 'PER_X_KG_FLAT' then { value: data[:kg], base: data[:base] }
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
