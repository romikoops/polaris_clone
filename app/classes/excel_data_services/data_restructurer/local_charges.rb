# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    class LocalCharges < Base
      HubNotFoundError = Class.new(WillBeRefactoredRestructuringError)

      def perform
        chunked_raw_data_per_sheet = data.values.map do |per_sheet_values|
          expanded_values = expand_fcl_to_all_sizes(per_sheet_values[:rows_data])
          rows_chunked_by_identifier = expanded_values.group_by { |row| row_identifier(row) }.values
          rows_chunked_by_identifier.map do |rows|
            rows_chunked_by_ranges = rows.group_by { |row| range_identifier(row) }.values
            sort_chunks_by_range_min(rows_chunked_by_ranges)
          end
        end

        charges_data = build_charges_data(chunked_raw_data_per_sheet)
        create_missing_charge_categories(charges_data)
        assign_correct_hubs(charges_data)
      end

      private

      def expand_fcl_to_all_sizes(rows_data)
        plain_fcl_local_charges_params = rows_data.select { |params| params[:load_type] == 'fcl' }
        expanded_local_charges_params = %w(fcl_20 fcl_40 fcl_40_hq).reduce([]) do |memo, fcl_size|
          memo + plain_fcl_local_charges_params.map do |params|
            params.dup.tap do |param|
              param[:load_type] = fcl_size
            end
          end
        end
        rows_data = rows_data.reject { |params| params[:load_type] == 'fcl' }
        rows_data + expanded_local_charges_params
      end

      def row_identifier(row)
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

      def range_identifier(row)
        { rate_basis: row[:rate_basis].upcase, fee_code: row[:fee_code].upcase }
      end

      def sort_chunks_by_range_min(chunked_data)
        chunked_data.map { |range_chunks| range_chunks.sort_by { |row| row[:range_min] } }
      end

      def build_charges_data(chunked_raw_data_per_sheet)
        chunked_raw_data_per_sheet.flat_map do |data_per_sheet|
          data_per_sheet.map do |data_per_identifier|
            data_without_fees = row_identifier(data_per_identifier.to_a.dig(0, 0))
            data_with_fees = data_without_fees.merge(fees: {})

            data_per_identifier.each do |data_per_ranges|
              ranges_obj = { range: reduce_ranges_into_one_obj(data_per_ranges) }
              charge_data = data_per_ranges.first
              fees_obj = { charge_data[:fee_code] => standard_charge_params(charge_data) }
              if ranges_obj[:range]
                fees_obj[data[:fee_code]].merge!(ranges_obj)
              else
                fees_obj[charge_data[:fee_code]].merge!(specific_charge_params_for_reading(charge_data[:rate_basis], charge_data))
              end

              data_with_fees[:fees].merge!(fees_obj)
            end
            data_with_fees
          end
        end
      end

      def reduce_ranges_into_one_obj(data_per_ranges)
        ranges_obj = data_per_ranges.map do |single_data|
          next unless includes_range?(single_data)

          { currency: single_data[:currency],
            min: single_data[:range_min],
            max: single_data[:range_max],
            **specific_charge_params_for_reading(single_data[:rate_basis], single_data) }
        end

        ranges_obj.compact.empty? ? nil : ranges_obj
      end

      def includes_range?(row)
        row[:range_min] && row[:range_max]
      end

      def standard_charge_params(charge_data)
        rate_basis = charge_data[:rate_basis].upcase

        { currency: charge_data[:currency],
          expiration_date: charge_data[:expiration_date],
          effective_date: charge_data[:effective_date],
          key: charge_data[:fee_code],
          min: charge_data[:minimum],
          max: charge_data[:maximum],
          name: charge_data[:fee],
          rate_basis: rate_basis }
      end

      def specific_charge_params_for_reading(rate_basis, single_data)
        rate_basis = RateBasis.get_internal_key(rate_basis.upcase)

        case rate_basis
        when 'PER_SHIPMENT'
          { value: single_data[:shipment] }
        when 'PER_CONTAINER'
          { value: single_data[:container] }
        when 'PER_BILL'
          { value: single_data[:bill] }
        when 'PER_CBM'
          { value: single_data[:cbm] }
        when 'PER_KG'
          { value: single_data[:kg] }
        when 'PER_TON'
          { ton: single_data[:ton] }
        when 'PER_WM'
          { value: single_data[:wm] }
        when 'PER_ITEM'
          { value: single_data[:item] }
        when 'PER_CBM_TON'
          { ton: single_data[:ton], cbm: single_data[:cbm] }
        when 'PER_SHIPMENT_CONTAINER'
          { shipment: single_data[:shipment], container: single_data[:container] }
        when 'PER_BILL_CONTAINER'
          { container: single_data[:container], bill: single_data[:bill] }
        when 'PER_CBM_KG'
          { kg: single_data[:kg], cbm: single_data[:cbm] }
        when 'PER_KG_RANGE'
          { range_min: single_data[:range_min], range_max: single_data[:range_max], kg: single_data[:kg] }
        when 'PER_WM_RANGE'
          { range_min: single_data[:range_min], range_max: single_data[:range_max], wm: single_data[:wm] }
        when 'PER_X_KG_FLAT'
          { value: single_data[:kg], base: single_data[:base] }
        when 'PER_UNIT_TON_CBM_RANGE'
          { cbm: single_data[:cbm],
            ton: single_data[:ton],
            range_min: single_data[:range_min],
            range_max: single_data[:range_max] }
        end
      end

      def create_missing_charge_categories(charges_data)
        keys_and_names = charges_data.flat_map do |single_data|
          single_data[:fees].values.map { |fee| fee.slice(:key, :name) }
        end

        keys_and_names.uniq { |pair| pair[:key] }.each do |pair|
          ChargeCategory.from_code(pair[:key], tenant.id, pair[:name])
        end
      end

      def assign_correct_hubs(charges_data)
        charges_data.map do |params|
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
