# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class LocalCharges < ExcelDataServices::FileWriters::Base # rubocop:disable Metrics/ClassLength
      private

      def load_and_prepare_data
        return { 'Local Charges' => [] } if filtered_local_charges.empty?

        rows_data = []
        filtered_local_charges.each do |local_charge|
          hub = ::Legacy::Hub.find_by(id: local_charge.hub_id)
          next if hub.nil?

          local_charge['fees'].each_value do |fees|
            ranges = fees['range']

            if ranges.present?
              ranges.each do |range|
                rows_data << build_row_data(hub, local_charge, fees, range)
              end
            else
              rows_data << build_row_data(hub, local_charge, fees)
            end
          end
        end
        sort!(rows_data)

        { 'Local Charges' => rows_data }
      end

      def filtered_local_charges
        @filtered_local_charges ||= tenant.local_charges
                                          .current
                                          .where(sandbox: @sandbox)
                                          .yield_self do |result|
          mot = options['mode_of_transport']
          result = result.for_mode_of_transport(mot) if mot.present? && !mot.casecmp?('all')
          result = result.where(group_id: options['group_id']) if options['group_id'].present?
          result
        end
      end

      def build_row_data(hub, local_charge, fee, range = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        rate_basis = fee['rate_basis'].upcase
        effective_date = Date.parse(local_charge.effective_date.to_s) if local_charge.effective_date
        expiration_date = Date.parse(local_charge.expiration_date.to_s) if local_charge.expiration_date
        counterpart_hub = tenant.hubs.find_by(id: local_charge.counterpart_hub_id)
        counterpart_hub_name = remove_hub_suffix(counterpart_hub.name, counterpart_hub.hub_type) if counterpart_hub
        counterpart_country_name = counterpart_hub.address.country.name if counterpart_hub
        tenant_vehicle = local_charge.tenant_vehicle

        { group_id: local_charge.group_id,
          group_name: Tenants::Group.find_by(id: local_charge.group_id)&.name,
          hub: remove_hub_suffix(hub.name, hub.hub_type),
          country: hub.address.country.name,
          effective_date: effective_date,
          expiration_date: expiration_date,
          counterpart_hub: counterpart_hub_name,
          counterpart_country: counterpart_country_name,
          service_level: tenant_vehicle.name,
          carrier: tenant_vehicle&.carrier&.name,
          fee_code: fee['key'],
          fee: fee['name'],
          mot: local_charge.mode_of_transport,
          load_type: local_charge.load_type,
          direction: local_charge.direction,
          currency: fee['currency'],
          rate_basis: rate_basis,
          minimum: fee['min'],
          maximum: fee['max'],
          **specific_charge_params_for_writing(rate_basis, fee, range),
          range_min: range['min'],
          range_max: range['max'],
          dangerous: local_charge.dangerous }
      end

      def specific_charge_params_for_writing(rate_basis, fee, range)
        rate_basis = RateBasis.get_internal_key(rate_basis)
        lookup = dynamic_lookup(fee, range)

        unless lookup.key?(rate_basis)
          raise ExcelDataServices::Validators::ValidationErrors::WritingError::UnknownRateBasisError,
                "RATE_BASIS \"#{rate_basis}\" not found!"
        end

        lookup[rate_basis]
      end

      def dynamic_lookup(fee, range)
        fee_value = fee['value']

        { 'PER_SHIPMENT' => { shipment: fee_value },
          'PER_CONTAINER' => { container: fee_value },
          'PER_BILL' => { bill: fee_value },
          'PER_CBM' => { cbm: fee_value },
          'PER_KG' => { kg: fee_value },
          'PER_WM' => { wm: fee_value },
          'PER_ITEM' => { item: fee_value },
          'PER_TON' => { ton: fee['ton'] },
          'PER_CBM_KG' => { kg: fee['kg'], cbm: fee['cbm'] },
          'PER_CBM_TON' => { ton: fee['ton'], cbm: fee['cbm'] },
          'PER_SHIPMENT_CONTAINER' => { shipment: fee['shipment'], container: fee['container'] },
          'PER_BILL_CONTAINER' => { container: fee['container'], bill: fee['bill'] },
          'PER_X_KG_FLAT' => { kg: fee_value, base: fee['base'] },
          'PER_KG_RANGE' => { kg: range['kg'] },
          'PER_KG_RANGE_FLAT' => { kg: range['kg'] },
          'PER_CBM_RANGE' => { kg: range['cbm'] },
          'PER_CBM_RANGE_FLAT' => { cbm: range['cbm'] },
          'PER_WM_RANGE' => { wm: range['wm'] },
          'PER_WM_RANGE_FLAT' => { wm: range['wm'] },
          'PER_UNIT_RANGE' => { unit: range['unit'] },
          'PER_UNIT_RANGE_FLAT' => { unit: range['unit'] },
          'PER_UNIT_TON_CBM_RANGE' => per_unit_ton_cbm_range_value(range) }
      end

      def per_unit_ton_cbm_range_value(range)
        if range['cbm'] && range['ton']
          raise ExcelDataServices::Validators::ValidationErrors::WritingError::PerUnitTonCbmRangeError,
                "There should only be one value for rate_basis 'PER_UNIT_TON_CBM_RANGE'."
        end

        if range['cbm']
          { cbm: range['cbm'] }
        elsif range['ton']
          { ton: range['ton'] }
        end
      end

      def sort!(data)
        data.sort_by! do |h|
          [
            *%i[group_id
                mot
                direction
                country
                hub
                counterpart_country
                counterpart_hub
                load_type].map { |col| h[col] || '' },
            h[:effective_date].to_s || '',
            h[:expiration_date].to_s || '',
            *%i[carrier
                service_level
                rate_basis
                fee_code
                fee
                minimum
                maximum
                currency
                range_min
                range_max].map { |col| h[col] || '' },
            h[:dangerous] ? 1 : -1
          ]
        end
      end

      def build_raw_headers(_sheet_name, _rows_data)
        ExcelDataServices::Validators::HeaderChecker::StaticHeadersForRestructurers::OPTIONAL_LOCAL_CHARGES +
          ExcelDataServices::Validators::HeaderChecker::StaticHeadersForRestructurers::LOCAL_CHARGES
      end
    end
  end
end
