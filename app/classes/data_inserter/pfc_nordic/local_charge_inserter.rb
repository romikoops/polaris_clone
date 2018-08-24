# frozen_string_literal: true

module DataInserter
  module PfcNordic
    class LocalChargeInserter < DataInserter::BaseInserter
      attr_reader :path, :_user, :hub_data, :hub_type, :hub, :input_language, :direction, :counterpart_hub_name, :data

      def post_initialize(args)
        @user = args[:_user]
        @hub_type = args[:hub_type]
        @data = args[:data]
        @checked_hubs = []
        @counterpart_hub = @user.tenant.hubs.find_by_name(args[:counterpart_hub_name])
        @direction = args[:direction]
      end

      def perform
        assign_local_charges
      end

      private

      def _stats
        {
          type:    "hubs",
          ports:   {
            number_updated: 0,
            number_created: 0
          },
          nexuses: {
            number_updated: 0,
            number_created: 0
          }
        }
      end

      def _results
        {
          ports:   [],
          nexuses: []
        }
      end

      def determine_local_charge_type
        if @hub_data[:routing]&.include?("RTM") && @direction == "import"
          rtm_charge
        elsif @hub_data[:country] && @hub_data[:country] == "Japan" && @direction == "export"
          japan_charge
        elsif @hub_data[:country] && (@hub_data[:country] == "United States of America" || @hub_data[:country] == "Usa") && @direction == "export"
          us_charge
        else
          LocalCharge.new
        end
      end

      def rtm_charge
        charge = @user.tenant.hubs.find_by_name("Dalian Port").local_charges.where(load_type: "lcl", direction: "export").first.as_json
        charge.delete("id")
        charge["counterpart_hub_id"] = @counterpart_hub.id
        charge["tenant_vehicle_id"] = @tenant_vehicle.id

        @charge = @hub.local_charges.find_or_create_by!(charge)
      end

      def us_charge
        hub = @user.tenant.hubs.find_by_name("Chattanooga Port")
        charge = hub.local_charges.where(load_type: "lcl", direction: "import").first.as_json
        charge.delete("id")
        charge["counterpart_hub_id"] = @counterpart_hub.id
        charge["tenant_vehicle_id"] = @tenant_vehicle.id

        @charge = @hub.local_charges.find_or_create_by!(charge)
      end

      def japan_charge
        charge = @user.tenant.hubs.find_by_name("Kobe Port").local_charges.where(load_type: "lcl", direction: "import").first.as_json
        charge.delete("id")
        charge["counterpart_hub_id"] = @counterpart_hub.id
        charge["tenant_vehicle_id"] = @tenant_vehicle.id

        @charge = @hub.local_charges.find_or_create_by!(charge)
      end

      def find_tenant_vehicle
        service_level = @hub_data[:service_level] || "standard"
        vehicle = TenantVehicle.find_by(name: service_level, mode_of_transport: @hub_data[:mot], tenant_id: @user.tenant_id)
        @tenant_vehicle = vehicle.presence || Vehicle.create_from_name(service_level, @hub_data[:mot], @user.tenant_id)
      end

      def assign_local_charges
        @data.each do |hub_obj|
          @hub_data = hub_obj[:data][:data]
          @hub = hub_obj[:hub]
          find_tenant_vehicle
          determine_local_charge_type
          awesome_print @charge
        end
      end
    end
  end
end
