# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserters
    class LocalCharges < Base # rubocop:disable Metrics/ClassLength
      def perform
        create_missing_charge_categories(data)
        assign_correct_hubs(data)

        data.each do |params|
          carriers(params).each do |carrier|
            tenant_vehicles = find_or_create_tenant_vehicles(params, carrier)
            tenant_vehicles.each do |tenant_vehicle|
              find_or_create_local_charges(params, tenant_vehicle)
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
          ChargeCategory.from_code(code: pair[:key], tenant_id: tenant.id, name: pair[:name], sandbox: @sandbox)
        end
      end

      def assign_correct_hubs(charges_data)
        charges_data.each do |params|
          origin_hub, = find_hub_by_name_or_locode_with_info(
            raw_name: params[:hub],
            mot: params[:mot],
            locode: params[:hub_locode]
          )
          params[:hub_id] = origin_hub.id

          if params[:counterpart_hub]
            if params[:counterpart_hub].downcase.casecmp('all').zero?
              counterpart_hub_id = nil
            else
              counterpart_hub, = find_hub_by_name_or_locode_with_info(
                raw_name: params[:counterpart_hub],
                mot: params[:mot],
                locode: params[:counterpart_hub_locode]
              )
              counterpart_hub_id = counterpart_hub.id
            end
          end

          params[:counterpart_hub_id] = counterpart_hub_id
        end
      end

      def carriers(params)
        return [nil] unless params[:carrier]
        return all_carriers_of_tenant if params[:carrier].downcase.casecmp('all').zero?

        [Carrier.find_or_create_by(name: params[:carrier])]
      end

      def all_carriers_of_tenant
        @all_carriers_of_tenant ||= Carrier.where(
          id: tenant.tenant_vehicles.where(sandbox: @sandbox).pluck(:carrier_id).compact.uniq
        )
      end

      def find_or_create_tenant_vehicles(params, carrier)
        service_level = params[:service_level]
        if service_level.downcase.casecmp('all').zero?
          return TenantVehicle.where(
            carrier: carrier,
            tenant: tenant,
            mode_of_transport: params[:mot],
            sandbox: @sandbox
          )
        end

        tenant_vehicle = TenantVehicle.find_by(
          name: service_level,
          mode_of_transport: params[:mot],
          tenant_id: tenant.id,
          carrier: carrier,
          sandbox: @sandbox
        )

        # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
        tenant_vehicle ||= Vehicle.create_from_name(
          name: service_level,
          mot: params[:mot],
          tenant_id: tenant.id,
          carrier_name: carrier&.name,
          sandbox: @sandbox
        ) # returns a `TenantVehicle`!

        [tenant_vehicle]
      end

      def find_or_create_local_charges(params, tenant_vehicle) # rubocop:disable Metrics/MethodLength
        params[:mode_of_transport] = params[:mot]
        params[:tenant_vehicle_id] = tenant_vehicle.id

        local_charge_params =
          params.slice(
            :internal,
            :load_type,
            :direction,
            :dangerous,
            :fees,
            :hub_id,
            :counterpart_hub_id,
            :mode_of_transport,
            :tenant_vehicle_id
          ).merge(
            effective_date: Date.parse(params[:effective_date].to_s).beginning_of_day,
            expiration_date: Date.parse(params[:expiration_date].to_s).end_of_day.change(usec: 0),
            sandbox: @sandbox,
            group_id: @group_id
          )

        new_local_charge = tenant.local_charges.new(local_charge_params)
        old_local_charges = tenant.local_charges.where(
          local_charge_params.except(:fees, :effective_date, :expiration_date, :internal)
        )
        overlap_handler = ExcelDataServices::DatabaseInserters::DateOverlapHandler
                          .new(old_local_charges, new_local_charge)
        local_charges_with_actions = overlap_handler.perform

        act_on_overlapping_local_charges(local_charges_with_actions)
      end

      def act_on_overlapping_local_charges(local_charges_with_actions)
        local_charges_with_actions.slice(:destroy).values.each do |local_charges|
          local_charges.each do |local_charge|
            local_charge.destroy
            add_stats(local_charge)
          end
        end

        local_charges_with_actions.slice(:save).values.flat_map do |local_charges|
          local_charges.map do |local_charge|
            add_stats(local_charge)
            local_charge.save!
            local_charge
          end
        end
      end
    end
  end
end
