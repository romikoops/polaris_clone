# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class LocalCharges < Base
      def perform
        data.each do |params|
          params[:fees].each do |fee_code, values|
            ChargeCategory.find_or_create_by!(
              code: fee_code.downcase,
              name: values[:name],
              tenant_id: tenant.id
            )
          end

          carriers(params).each do |carrier|
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

      def carriers(params)
        if params[:carrier] == 'all'
          all_carriers_of_tenant
        elsif params[:carrier]
          [Carrier.find_or_create_by(name: params[:carrier])]
        else
          [nil]
        end
      end

      def all_carriers_of_tenant
        @all_carriers_of_tenant ||= Carrier.where(id: @tenant.tenant_vehicles.pluck(:carrier_id).compact.uniq)
      end

      def find_or_create_tenant_vehicles(params, carrier)
        service_level = params[:service_level]
        if service_level == 'all'
          return TenantVehicle.where(
            carrier: carrier,
            tenant: @tenant,
            mode_of_transport: params[:mot]
          )
        end

        tenant_vehicle = TenantVehicle.find_by(
          name: service_level,
          mode_of_transport: params[:mot],
          tenant_id: @tenant.id,
          carrier: carrier
        )

        # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
        tenant_vehicle ||= Vehicle.create_from_name(
          service_level,
          params[:mot],
          @tenant.id,
          carrier.name
        ) # returns a `TenantVehicle`!

        [tenant_vehicle]
      end

      def find_or_create_local_charge(params, tenant_vehicle)
        params[:mode_of_transport] = params[:mot]
        params[:tenant_vehicle_id] = tenant_vehicle.id

        local_charge_params =
          params.slice(
            :load_type,
            :direction,
            :dangerous,
            :fees,
            :hub_id,
            :counterpart_hub_id,
            :mode_of_transport,
            :tenant_vehicle_id
          ).merge(
            effective_date: Date.parse(params[:effective_date]),
            expiration_date: Date.parse(params[:expiration_date])
          )

        local_charge = @tenant.local_charges.find_or_initialize_by(local_charge_params)
        add_stats(:local_charges, local_charge)
        local_charge.tap(&:save!)
      end
    end
  end
end
