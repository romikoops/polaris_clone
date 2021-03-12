# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class LocalCharges < ExcelDataServices::Inserters::Base
      def perform
        create_missing_charge_categories(data)
        assign_correct_hubs(data)

        data.each do |params|
          carriers(params).each do |carrier|
            tenant_vehicles = find_or_create_tenant_vehicles(params, carrier)
            tenant_vehicles.each do |tenant_vehicle|
              find_or_create_local_charges(params, tenant_vehicle.id)
            end
          end
        end

        stats
      end

      private

      def create_missing_charge_categories(charges_data)
        keys_and_names = charges_data.flat_map { |single| single[:fees].values.map { |fee| fee.slice(:key, :name) } }
        keys_and_names.uniq { |pair| pair[:key] }.each do |pair|
          Legacy::ChargeCategory.from_code(code: pair[:key], organization_id: organization.id, name: pair[:name])
        end
      end

      def assign_correct_hubs(charges_data)
        charges_data.each do |params|
          row = ExcelDataServices::Rows::Base.get(klass_identifier).new(
            row_data: params, organization: organization
          )

          origin_hub_with_info = find_hub_by_name_or_locode_with_info(
            name: row.hub,
            country: row.hub_country,
            mot: row.mot,
            locode: row.hub_locode
          )

          params[:hub_id] = origin_hub_with_info[:hub].id

          next params[:counterpart_hub_id] = nil unless row.counterpart_hub || row.counterpart_locode

          counterpart_hub_with_info = find_hub_by_name_or_locode_with_info(
            name: row.counterpart_hub,
            country: row.counterpart_country,
            mot: row.mot,
            locode: row.counterpart_locode
          )
          params[:counterpart_hub_id] = counterpart_hub_with_info[:hub].id
        end
      end

      def carriers(params)
        return [nil] unless params[:carrier]
        return all_carriers_of_tenant if params[:carrier].downcase.casecmp?("all")

        [carrier_from_code(name: params[:carrier])]
      end

      def all_carriers_of_tenant
        @all_carriers_of_tenant ||= Legacy::Carrier.where(
          id: Legacy::TenantVehicle.where(organization_id: organization.id).pluck(:carrier_id).compact.uniq
        )
      end

      def find_or_create_tenant_vehicles(params, carrier)
        service_level = params[:service_level]
        tv_params = {name: service_level,
                     carrier: carrier,
                     organization: organization,
                     mode_of_transport: params[:mot]}
        tv_params.delete(:name) if service_level.casecmp?("all")

        # FIX: `Vehicle` shouldn't be creating a `TenantVehicle`!
        Legacy::TenantVehicle.where(tv_params).presence ||
          [Legacy::Vehicle.create_from_name(
            name: service_level,
            carrier_name: carrier&.name,
            organization_id: organization.id,
            mot: params[:mot]
          )]
      end

      def find_or_create_local_charges(params, tenant_vehicle_id)
        local_charge_params = prepare_params(params, tenant_vehicle_id)
        old_local_charges = ::Legacy::LocalCharge.where(
          local_charge_params.except(:fees, :effective_date, :expiration_date, :internal, :metadata)
        )
        new_local_charge = ::Legacy::LocalCharge.new(local_charge_params)

        local_charges_with_actions =
          ExcelDataServices::Inserters::DateOverlapHandler.new(old_local_charges, new_local_charge).perform

        act_on_overlapping_local_charges(local_charges_with_actions, params[:row_nr])
      end

      def prepare_params(params, tenant_vehicle_id)
        params.slice(
          :internal,
          :load_type,
          :direction,
          :dangerous,
          :fees,
          :hub_id,
          :counterpart_hub_id
        ).merge(
          organization_id: organization.id,
          effective_date: Date.parse(params[:effective_date].to_s).beginning_of_day,
          expiration_date: Date.parse(params[:expiration_date].to_s).end_of_day.change(usec: 0),
          mode_of_transport: params[:mot],
          tenant_vehicle_id: tenant_vehicle_id,
          group_id: @group_id.presence || params[:group_id] || default_group.id,
          metadata: metadata(row: params)
        )
      end

      def act_on_overlapping_local_charges(local_charges_with_actions, row_nr)
        local_charges_with_actions.slice(:destroy).values.each do |local_charges|
          local_charges.each do |local_charge|
            local_charge.destroy
            add_stats(local_charge, row_nr)
          end
        end

        local_charges_with_actions.slice(:save).values.flat_map do |local_charges|
          local_charges.map do |local_charge|
            add_stats(local_charge, row_nr)
            local_charge.save
            local_charge
          end
        end
      end
    end
  end
end
