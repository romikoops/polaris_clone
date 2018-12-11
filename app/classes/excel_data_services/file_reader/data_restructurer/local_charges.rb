# frozen_string_literal: true

module ExcelDataServices
  module FileReader
    module DataRestructurer
      module LocalCharges
        MissingValuesForRateBasisError = Class.new(ExcelDataServices::FileReader::Base::ParsingError)

        private

        def assign_correct_hubs(data)
          data.map do |params|
            mot = params[:mot]

            begin
              hub_name = append_hub_suffix(params[:hub], mot)
              hub_id = @tenant.hubs.find_by(name: hub_name, hub_type: mot).id
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
                  counterpart_hub = @tenant.hubs.find_by(name: counterpart_hub_name, hub_type: mot)
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

        def expand_fcl_to_all_sizes(data)
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

        def build_charge_params_from_row_with_error_data(row)
          rate_basis = RateBasis.get_internal_key(row[:rate_basis].upcase)
          standard_charge_params =
            { currency: row[:currency],
              expiration_date: row[:expiration_date],
              effective_date: row[:effective_date],
              name: row[:fee],
              key: row[:fee_code],
              min: row[:min],
              max: row[:maximum],
              rate_basis: row[:rate_basis] }

          specific_charge_params = specific_charge_params_for_reading(rate_basis, row)
          error_data = specific_charge_params.values.reduce([]) do |error_info, value|
            error_info << { row_nr: row[:row_nr], rate_basis_name: rate_basis.upcase } if value.nil?
          end

          ChargeCategory.find_or_create_by!(code: row[:fee_code], name: row[:fee], tenant_id: tenant.id)

          charge_params = { charge_params: standard_charge_params.merge(specific_charge_params) }
          charge_params.merge(error_data: error_data)
        end

        def build_charge_params(data)
          all_local_charges_params = []
          data.values.each do |per_sheet_values|
            chunked_rows_data = per_sheet_values[:rows_data].chunk do |row|
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

            all_error_strings = []
            per_sheet_local_charges_params = chunked_rows_data.map do |local_charge_identifier, rows|
              params = local_charge_identifier
              params[:fees] = {}
              rows.each do |row|
                charge_params_with_error_data = build_charge_params_from_row_with_error_data(row)

                if charge_params_with_error_data[:error_data]
                  error_strings = charge_params_with_error_data[:error_data].map do |error|
                    "Missing value for #{error[:rate_basis_name]} in row ##{error[:row_nr]}! Did you enter the value in the correct column?"
                  end
                  all_error_strings << error_strings.join("\n")
                end

                charge_params = charge_params_with_error_data[:charge_params]
                params[:fees][row[:fee_code]] = charge_params
              end

              params
            end

            raise MissingValuesForRateBasisError, all_error_strings.join("\n") unless all_error_strings.empty?
            all_local_charges_params += per_sheet_local_charges_params
          end
          all_local_charges_params
        end

        def restructure_data(data)
          restructured_data = build_charge_params(data)
          restructured_data = expand_fcl_to_all_sizes(restructured_data)
          assign_correct_hubs(restructured_data)
        end
      end
    end
  end
end
