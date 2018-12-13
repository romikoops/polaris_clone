# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class LocalCharges < Base
      include ExcelDataServices::LocalChargesTool

      def perform
        available_carriers = all_carriers_of_tenant

        data.each do |params|
          params[:fees].each do |fee_code, values|
            ChargeCategory.find_or_create_by!(code: fee_code,
                                              name: values[:name],
                                              tenant_id: tenant.id)
          end

          if params[:carrier] == 'all'
            available_carriers.each do |carrier|
              tenant_vehicles = find_or_create_tenant_vehicles(params, carrier)
              tenant_vehicles.each do |tenant_vehicle|
                find_or_create_local_charge(params, tenant_vehicle)
              end
            end
          else
            carrier = Carrier.find_or_create_by(name: params[:carrier])
            tenant_vehicles = find_or_create_tenant_vehicles(params, carrier)
            tenant_vehicles.each do |tenant_vehicle|
              find_or_create_local_charge(params, tenant_vehicle)
            end
          end
        end

        stats
      end

      private

      def stat_descriptors
        %i(local_charges)
      end

      def all_carriers_of_tenant
        Carrier.where(id: @tenant.tenant_vehicles.pluck(:carrier_id).compact.uniq)
      end

      def find_or_create_tenant_vehicles(params, carrier)
        service_level = service_level(params)
        if service_level(params) == 'all'
          return TenantVehicle.where(carrier: carrier,
                                     tenant: @tenant,
                                     mode_of_transport: params[:mot])
        end

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

      def find_or_create_local_charge(params, tenant_vehicle)
        params[:mode_of_transport] = params[:mot]
        params[:tenant_vehicle_id] = tenant_vehicle.id
        local_charge_params = params.except(:mot,
                                            :hub,
                                            :country,
                                            :counterpart_hub,
                                            :counterpart_country,
                                            :carrier,
                                            :service_level)

        local_charge = @tenant.local_charges.find_or_initialize_by(local_charge_params)
        add_stats(:local_charges, local_charge)
        local_charge.tap(&:save!)
      end
    end
  end
end
