# frozen_string_literal: true

module DataInserter
  class LocalChargesInserter < BaseInserter
    def perform
      super

      data = format_to_legacy(@data)

      data.each_with_index do |(k_sheet_name, values), sheet_i|
        values[:rows_data].each_with_index do |row, row_i|
          tenant_vehicle = find_or_create_tenant_vehicle(row)
          find_or_create_local_charges(row, tenant_vehicle)

          puts "Status: Sheet \"#{k_sheet_name}\" (##{sheet_i + 1}) | Row ##{row_i + 1}"
        end
      end
    end

    private

    def data_valid?(_data)
      # TODO: Implement validation
      true
    end

    def errors_from_charge_params_with_errors(charge_params_with_errors)
      charge_params_with_errors[:errors]
    end

    def format_to_legacy(data)
      all_local_charges_params = []
      data.values.each do |per_sheet_values|
        chunked_rows_data = per_sheet_values[:rows_data].chunk do |row|
          row.slice(:port,
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

        error_strings = []
        per_sheet_local_charges_params = chunked_rows_data.map do |local_charge_identifier, rows|
          local_charge_params = local_charge_identifier
          local_charge_params[:fees] = {}
          rows.each do |row|
            charge_params_with_errors = build_charge_params_with_error_data(row)
            if charge_params_with_errors[:errors]
              error_strings << charge_params_with_errors[:errors].map { |error| "Missing value for #{error[:rate_basis_name]} in row ##{error[:row_nr]}! Did you enter the value in the correct column?" }.join("\n")
            end
            charge_params = charge_params_with_errors[:charge_params]
            local_charge_params[:fees][row[:fee_code]] = charge_params
          end
          local_charge_params
        end

        raise StandardError, error_strings.join("\n") unless error_strings.empty?
        all_local_charges_params += per_sheet_local_charges_params
      end
      all_local_charges_params
    end

    def service_level(row)
      row[:service_level] || 'standard'
    end

    def find_or_create_carrier(row)
      Carrier.find_or_create_by(name: row[:carrier])
    end

    def find_or_create_tenant_vehicle(row)
      service_level = service_level(row)
      carrier = find_or_create_carrier(row)
      tenant_vehicle = TenantVehicle.find_by(name: service_level,
                                             mode_of_transport: row[:mot],
                                             tenant_id: @tenant.id,
                                             carrier: carrier)

      # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
      tenant_vehicle || Vehicle.create_from_name(service_level,
                                                 row[:mot],
                                                 @tenant.id,
                                                 carrier.name) # returns a `TenantVehicle`!
    end

    def find_or_create_local_charges(row, tenant_vehicle)
      charge_params = build_charge_params(row)
      local_charge = LocalCharge.find_or_initialize_by(charge_params)
      local_charge.tenant_vehicle = tenant_vehicle
      local_charge.save!
    end

    def build_charge_params_with_error_data(row)
      rate_basis = RateBasis.get_internal_key(row[:rate_basis].upcase)
      standard_charge_params = { currency: row[:currency],
                                 expiration_date: row[:expiration_date],
                                 effective_date: row[:effective_date],
                                 name: row[:fee],
                                 key: row[:fee_code],
                                 min: row[:min],
                                 max: row[:maximum],
                                 rate_basis: row[:rate_basis] }

      specific_charge_params = case rate_basis
                               when 'PER_SHIPMENT' then { value: row[:shipment] }
                               when 'PER_CONTAINER' then { value: row[:container] }
                               when 'PER_BILL' then { value: row[:bill] }
                               when 'PER_CBM' then { value: row[:cbm] }
                               when 'PER_KG' then { value: row[:kg] }
                               when 'PER_TON' then { ton: row[:ton] }
                               when 'PER_WM' then { value: row[:wm] }
                               when 'PER_ITEM' then { value: row[:item] }
                               when 'PER_CBM_TON' then { ton: row[:ton], cbm: row[:cbm] }
                               when 'PER_SHIPMENT_CONTAINER' then { shipment: row[:shipment], container: row[:container] }
                               when 'PER_BILL_CONTAINER' then { container: row[:container], bill: row[:bill] }
                               when 'PER_CBM_KG' then { kg: row[:kg], cbm: row[:cbm] }
                               when 'PER_KG_RANGE' then { range_min: row[:range_min], range_max: row[:range_max], kg: row[:kg] }
                               when 'PER_X_KG_FLAT' then { value: row[:kg], base: row[:base] }
                               else
                                 raise StandardError, "RATE_BASIS \"#{row[:rate_basis].upcase}\" not found!"
                               end

      errors = specific_charge_params.values.reduce([]) do |memo, value|
        memo << { row_nr: row[:row_nr], rate_basis_name: rate_basis.upcase } if value.nil?
      end

      ChargeCategory.find_or_create_by!(code: row[:fee_code], name: row[:fee])

      charge_params = { charge_params: standard_charge_params.merge(specific_charge_params) }
      charge_params.merge(errors: errors)
    end
  end
end
