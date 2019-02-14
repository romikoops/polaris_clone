# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class LocalCharges < Base # rubocop:disable Metrics/ClassLength
      def perform
        create_missing_charge_categories(data)
        assign_correct_hubs(data)

        data.each do |params|
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

      def create_missing_charge_categories(charges_data)
        keys_and_names = charges_data.flat_map do |single_data|
          single_data[:fees].values.map { |fee| fee.slice(:key, :name) }
        end

        keys_and_names.uniq { |pair| pair[:key] }.each do |pair|
          ChargeCategory.from_code(pair[:key], tenant.id, pair[:name])
        end
      end

      def assign_correct_hubs(charges_data)
        charges_data.each do |params|
          mot = params[:mot]

          hub = Hub.find_by(tenant: tenant, name: params[:hub_name], hub_type: mot)
          unless hub
            raise ExcelDataServices::DataValidator::ValidationError::Insertability::HubsNotFound,
                  "Hub \"#{params[:hub_name]}\" not found!"
          end
          params[:hub_id] = hub.id

          if params[:counterpart_hub]
            counterpart_hub_id =
              if params[:counterpart_hub] == 'all'
                nil
              else
                counterpart_hub = tenant.hubs.find_by(name: params[:counterpart_hub_name], hub_type: mot)
                unless counterpart_hub
                  raise ExcelDataServices::DataValidator::ValidationError::Insertability::HubsNotFound,
                        "Counterpart Hub with name \"#{params[:counterpart_hub_name]}\" not found!"
                end

                counterpart_hub.id
              end
          end

          params[:counterpart_hub_id] = counterpart_hub_id
        end
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
        @all_carriers_of_tenant ||= Carrier.where(id: tenant.tenant_vehicles.pluck(:carrier_id).compact.uniq)
      end

      def find_or_create_tenant_vehicles(params, carrier)
        service_level = params[:service_level]
        if service_level == 'all'
          return TenantVehicle.where(
            carrier: carrier,
            tenant: tenant,
            mode_of_transport: params[:mot]
          )
        end

        tenant_vehicle = TenantVehicle.find_by(
          name: service_level,
          mode_of_transport: params[:mot],
          tenant_id: tenant.id,
          carrier: carrier
        )

        # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
        tenant_vehicle ||= Vehicle.create_from_name(
          service_level,
          params[:mot],
          tenant.id,
          carrier.name
        ) # returns a `TenantVehicle`!

        [tenant_vehicle]
      end

      def find_or_create_local_charge(params, tenant_vehicle)
        params[:mode_of_transport] = params[:mot]
        params[:tenant_vehicle_id] = tenant_vehicle.id

        local_charge_params =
          params.slice(
            :uuid,
            :load_type,
            :direction,
            :dangerous,
            :fees,
            :hub_id,
            :counterpart_hub_id,
            :mode_of_transport,
            :tenant_vehicle_id
          ).merge(
            effective_date: Date.parse(params[:effective_date].to_s),
            expiration_date: Date.parse(params[:expiration_date].to_s)
          )

        local_charge =
          tenant.local_charges.find_by(uuid: params[:uuid]) ||
          tenant.local_charges.find_or_initialize_by(local_charge_params)
        add_stats(:local_charges, local_charge)
        local_charge.tap(&:save!)
      end
    end
  end
end
