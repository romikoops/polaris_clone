# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class LocalCharges < Base
      HubNotFoundError = Class.new(WillBeRefactoredRestructuringError)

      def self.restructure_data(data, tenant)
        chunked_raw_data_per_sheet = data.values.map do |per_sheet_values|
          expanded_values = expand_fcl_to_all_sizes(per_sheet_values[:rows_data])
          rows_chunked_by_identifier = expanded_values.group_by { |row| row_identifier(row) }.values
          rows_chunked_by_identifier.map do |rows|
            rows_chunked_by_ranges = rows.group_by { |row| range_identifier(row) }.values
            sort_chunks_by_range_min(rows_chunked_by_ranges)
          end
        end

        charges_data = build_charges_data(chunked_raw_data_per_sheet)
        create_missing_charge_categories(charges_data, tenant)
        assign_correct_hubs(charges_data, tenant)
      end

      def self.expand_fcl_to_all_sizes(data)
        plain_fcl_local_charges_params = data.select { |params| params[:load_type] == 'fcl' }
        expanded_local_charges_params = %w(fcl_20 fcl_40 fcl_40_hq).reduce([]) do |memo, fcl_size|
          memo + plain_fcl_local_charges_params.map do |params|
            params.dup.tap do |param|
              param[:load_type] = fcl_size
            end
          end
        end
        data = data.reject { |params| params[:load_type] == 'fcl' }
        data + expanded_local_charges_params
      end

      def self.row_identifier(row)
        row.slice(:hub,
                  :country,
                  :counterpart_hub,
                  :counterpart_country,
                  :service_level,
                  :carrier,
                  :mot,
                  :load_type,
                  :direction,
                  :dangerous)
      end

      def self.range_identifier(row)
        { rate_basis: row[:rate_basis].upcase, fee_code: row[:fee_code].upcase }
      end

      def self.sort_chunks_by_range_min(chunked_data)
        chunked_data.map { |range_chunks| range_chunks.sort_by { |row| row[:range_min] } }
      end

      def self.build_charges_data(chunked_raw_data_per_sheet)
        chunked_raw_data_per_sheet.flat_map do |data_per_sheet|
          data_per_sheet.map do |data_per_identifier|
            data_without_fees = row_identifier(data_per_identifier.to_a.dig(0, 0))
            data_with_fees = data_without_fees.merge(fees: {})

            data_per_identifier.each do |data_per_ranges|
              ranges_obj = { range: reduce_ranges_into_one_obj(data_per_ranges) }
              data = data_per_ranges.first
              fees_obj = { data[:fee_code] => standard_charge_params(data) }
              if ranges_obj[:range]
                fees_obj[data[:fee_code]].merge!(ranges_obj)
              else
                fees_obj[data[:fee_code]].merge!(specific_charge_params_for_reading(data[:rate_basis], data))
              end

              data_with_fees[:fees].merge!(fees_obj)
            end
            data_with_fees
          end
        end
      end

      def self.reduce_ranges_into_one_obj(data_per_ranges)
        ranges_obj = data_per_ranges.map do |single_data|
          next unless includes_range?(single_data)

          { currency: single_data[:currency],
            min: single_data[:range_min],
            max: single_data[:range_max],
            **specific_charge_params_for_reading(single_data[:rate_basis], single_data) }
        end

        ranges_obj.compact.empty? ? nil : ranges_obj
      end

      def self.includes_range?(row)
        row[:range_min] && row[:range_max]
      end

      def self.standard_charge_params(data)
        rate_basis = data[:rate_basis].upcase

        { currency: data[:currency],
          expiration_date: data[:expiration_date],
          effective_date: data[:effective_date],
          key: data[:fee_code],
          min: data[:minimum],
          max: data[:maximum],
          name: data[:fee],
          rate_basis: rate_basis }
      end

      def self.specific_charge_params_for_reading(rate_basis, data)
        rate_basis = RateBasis.get_internal_key(rate_basis.upcase)
        case rate_basis
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

      def self.create_missing_charge_categories(charges_data, tenant)
        keys_and_names = charges_data.flat_map do |single_data|
          single_data[:fees].values.map { |fee| fee.slice(:key, :name) }
        end

        keys_and_names.uniq { |pair| pair[:key] }.each do |pair|
          ChargeCategory.from_code(pair[:key], tenant.id, pair[:name])
        end
      end

      def self.assign_correct_hubs(data, tenant)
        data.map do |params|
          mot = params[:mot]

          begin
            hub_name = append_hub_suffix(params[:hub], mot)
            hub_id = tenant.hubs.find_by(name: hub_name, hub_type: mot).id
          rescue HubNotFoundError
            raise "Hub \"#{hub_name}\" not found!"
          end

          params[:hub_id] = hub_id
          if params[:counterpart_hub]
            counterpart_hub_id =
              if params[:counterpart_hub] == 'all'
                nil
              else
                counterpart_hub_name = append_hub_suffix(params[:counterpart_hub], mot)
                counterpart_hub = tenant.hubs.find_by(name: counterpart_hub_name, hub_type: mot)
                unless counterpart_hub
                  raise HubNotFoundError, "Counterpart Hub with name \"#{counterpart_hub_name}\" not found!"
                end

                counterpart_hub.id
              end
          end

          params[:counterpart_hub_id] = counterpart_hub_id
          params
        end
      end
    end
  end
end
