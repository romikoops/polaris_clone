# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class LocalCharges < ExcelDataServices::FileWriters::Base # rubocop:disable Metrics/ClassLength
      def initialize(tenant:, file_name:, mode_of_transport: nil, sandbox: nil)
        super(tenant: tenant, file_name: file_name)
        @mode_of_transport = mode_of_transport
      end

      private

      attr_reader :mode_of_transport

      def load_and_prepare_data
        rows_data = []
        all_local_charges = tenant.local_charges.where(sandbox: @sandbox, group_id: @group_id)
        local_charges = if mode_of_transport.nil? || mode_of_transport.casecmp?('all')
                          all_local_charges
                        else
                          all_local_charges.for_mode_of_transport(mode_of_transport)
                        end
        local_charges&.each do |local_charge|
          local_charge[:fees].values.each do |fee_values_h|
            ranges = ranges_in_fee_values(fee_values_h)

            ranges.each do |range|
              rows_data << build_row_data(local_charge, fee_values_h, range)
            end
          end
        end

        sort!(rows_data)

        { 'Local Charges' => rows_data }
      end

      def ranges_in_fee_values(fee_values_h)
        fee_values_h.with_indifferent_access[:range] || [nil]
      end

      def build_row_data(local_charge, fee, range) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        fee.deep_symbolize_keys!
        hub = tenant.hubs.find(local_charge.hub_id)
        hub_name = remove_hub_suffix(hub.name, hub.hub_type)
        country_name = hub.address.country.name
        effective_date = Date.parse(local_charge.effective_date.to_s) if local_charge.effective_date
        expiration_date = Date.parse(local_charge.expiration_date.to_s) if local_charge.expiration_date
        counterpart_hub = tenant.hubs.find_by(id: local_charge.counterpart_hub_id) # can be nil through `find_by`!
        counterpart_hub_name = remove_hub_suffix(counterpart_hub.name, counterpart_hub.hub_type) if counterpart_hub
        counterpart_country_name = counterpart_hub.address.country.name if counterpart_hub
        tenant_vehicle = local_charge.tenant_vehicle
        service_level = tenant_vehicle.name
        carrier = tenant_vehicle&.carrier&.name
        rate_basis = fee[:rate_basis].upcase
        unless range.nil?
          range_min = range[:min]
          range_max = range[:max]
        end

        { uuid: local_charge.uuid,
          hub: hub_name,
          country: country_name,
          effective_date: effective_date,
          expiration_date: expiration_date,
          counterpart_hub: counterpart_hub_name,
          counterpart_country: counterpart_country_name,
          service_level: service_level,
          carrier: carrier,
          fee_code: fee[:key],
          fee: fee[:name],
          mot: local_charge.mode_of_transport,
          load_type: local_charge.load_type,
          direction: local_charge.direction,
          currency: fee[:currency],
          rate_basis: fee[:rate_basis],
          minimum: fee[:min],
          maximum: fee[:max],
          **specific_charge_params_for_writing(rate_basis, fee, range),
          range_min: range_min,
          range_max: range_max,
          dangerous: local_charge.dangerous }
      end

      def specific_charge_params_for_writing(rate_basis, data, range) # rubocop:disable Metrics/AbcSize
        range = {} if range.nil?
        rate_basis = RateBasis.get_internal_key(rate_basis.upcase)

        lookup =
          { 'PER_SHIPMENT' => { shipment: data[:value] },
            'PER_CONTAINER' => { container: data[:value] },
            'PER_BILL' => { bill: data[:value] },
            'PER_CBM' => { cbm: data[:value] },
            'PER_KG' => { kg: data[:value]  },
            'PER_TON' => { ton: data[:ton]  },
            'PER_WM' => { wm: data[:value]  },
            'PER_ITEM' => { item: data[:value]  },
            'PER_CBM_TON' => { ton: data[:ton], cbm: data[:cbm] },
            'PER_SHIPMENT_CONTAINER' => { shipment: data[:shipment], container: data[:container] },
            'PER_BILL_CONTAINER' => { container: data[:container], bill: data[:bill] },
            'PER_CBM_KG' => { kg: data[:kg], cbm: data[:cbm] },
            'PER_KG_RANGE' => { kg: range[:kg]  },
            'PER_WM_RANGE' => { wm: range[:wm]  },
            'PER_X_KG_FLAT' => { kg: data[:value], base: data[:base] },
            'PER_UNIT_TON_CBM_RANGE' => per_unit_ton_cbm_range_value(range) }

        unless lookup.has_key?(rate_basis)
          raise ExcelDataServices::Validators::ValidationErrors::WritingError::UnknownRateBasisError,
                "RATE_BASIS \"#{rate_basis}\" not found!"
        end

        lookup[rate_basis]
      end

      def per_unit_ton_cbm_range_value(range)
        if range[:cbm] && range[:ton]
          raise ExcelDataServices::Validators::ValidationErrors::WritingError::PerUnitTonCbmRangeError,
                "There should only be one value for rate_basis 'PER_UNIT_TON_CBM_RANGE'."
        end

        if range[:cbm]
          { cbm: range[:cbm] }
        elsif range[:ton]
          { ton: range[:ton] }
        end
      end

      def sort!(data) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        data.sort_by! do |h|
          [
            h[:mot] || '',
            h[:direction] || '',
            h[:country] || '',
            h[:hub] || '',
            h[:counterpart_country] || '',
            h[:counterpart_hub] || '',
            h[:load_type] || '',
            h[:effective_date].to_s || '',
            h[:expiration_date].to_s || '',
            h[:carrier] || '',
            h[:service_level] || '',
            h[:rate_basis] || '',
            h[:fee_code] || '',
            h[:fee] || '',
            h[:minimum] || '',
            h[:maximum] || '',
            h[:currency] || '',
            h[:range_min] || '',
            h[:range_max] || '',
            h[:dangerous] ? 1 : -1
          ]
        end
      end

      def build_raw_headers(_sheet_name, _rows_data)
        ExcelDataServices::Validators::HeaderChecker::StaticHeadersForRestructurers::LOCAL_CHARGES
      end
    end
  end
end
