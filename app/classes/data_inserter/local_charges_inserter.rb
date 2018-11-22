# frozen_string_literal: true

module DataInserter
  class LocalChargesInserter < BaseInserter
    private

    def post_perform
      data = format_to_legacy(@data)
      data = expand_fcl_to_all_sizes(data)
      data = assign_correct_hubs(data)

      available_carriers = all_carriers_of_tenant

      data.each do |params|
        if params[:carrier] == 'all'
          available_carriers.each do |carrier|
            tenant_vehicles = find_or_create_tenant_vehicles(params, carrier)
            tenant_vehicles.each do |tenant_vehicle|
              find_or_create_local_charges(params, tenant_vehicle)
            end
          end
        else
          carrier = find_or_create_carrier(params)
          tenant_vehicles = find_or_create_tenant_vehicles(params, carrier)
          tenant_vehicles.each do |tenant_vehicle|
            find_or_create_local_charges(params, tenant_vehicle)
          end
        end
      end
    end

    def data_valid?(_data)
      # TODO: Implement validation
      true
    end

    def assign_correct_hubs(data)
      data.map do |params|
        mot = params[:mot]

        begin
          # TODO: `port` is wrong, should be hub!
          hub_name = append_hub_suffix(params[:port], mot)
          hub_id = @tenant.hubs.find_by(name: hub_name, hub_type: mot).id
        rescue StandardError
          raise "Hub \"#{hub_name}\" not found!"
        end

        params[:hub_id] = hub_id
        counterpart_hub_id = if params[:counterpart_hub] == 'all'
                               nil
                             else
                               @tenant.hubs.find_by(name: append_hub_suffix(params[:counterpart_hub], mot), hub_type: mot).id
                             end
        params[:counterpart_hub_id] = counterpart_hub_id
        params
      end
    end

    def all_carriers_of_tenant
      Carrier.where(id: @tenant.tenant_vehicles.pluck(:carrier_id).compact.uniq)
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
          params = local_charge_identifier
          params[:fees] = {}
          rows.each do |row|
            charge_params_with_errors = build_charge_params_with_error_data(row)
            if charge_params_with_errors[:errors]
              error_strings << charge_params_with_errors[:errors].map { |error| "Missing value for #{error[:rate_basis_name]} in row ##{error[:row_nr]}! Did you enter the value in the correct column?" }.join("\n")
            end
            charge_params = charge_params_with_errors[:charge_params]
            params[:fees][row[:fee_code]] = charge_params
          end
          params
        end

        raise StandardError, error_strings.join("\n") unless error_strings.empty?
        all_local_charges_params += per_sheet_local_charges_params
      end
      all_local_charges_params
    end

    def expand_fcl_to_all_sizes(data)
      plain_fcl_local_charges_params = data.select { |params| params[:load_type] == 'fcl' }
      expanded_local_charges_params = %w(fcl_20 fcl_40 fcl_40_hq).reduce([]) do |memo, fcl_size|
        memo + plain_fcl_local_charges_params.map do |params|
          temp = params.dup
          temp[:load_type] = fcl_size
          temp
        end
      end
      data = data.reject { |params| params[:load_type] == 'fcl' }
      data + expanded_local_charges_params
    end

    def service_level(params)
      params[:service_level] || 'standard'
    end

    def find_or_create_carrier(params)
      Carrier.find_or_create_by(name: params[:carrier])
    end

    def find_or_create_tenant_vehicles(params, carrier)
      service_level = service_level(params)
      return TenantVehicle.where(carrier: carrier, tenant: @tenant, mode_of_transport: params[:mot]) if service_level == 'all'

      tenant_vehicle = TenantVehicle.find_by(name: service_level,
                                             mode_of_transport: params[:mot],
                                             tenant_id: @tenant.id,
                                             carrier: carrier)

      # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
      tenant_vehicle ||= Vehicle.create_from_name(service_level,
                                                  params[:mot],
                                                  @tenant.id,
                                                  carrier.name) # returns a `TenantVehicle`!
      [tenant_vehicle]
    end

    def find_or_create_local_charges(params, tenant_vehicle)
      params[:mode_of_transport] = params[:mot]
      params[:tenant_vehicle_id] = tenant_vehicle.id
      local_charge_params = params.except(:mot, :port, :country, :counterpart_hub, :counterpart_country, :carrier, :service_level)
      local_charge = @tenant.local_charges.find_or_initialize_by(local_charge_params)
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
