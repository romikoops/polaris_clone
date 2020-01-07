# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Hubs < Base
      def perform
        data.each do |params|
          mandatory_charge = find_mandatory_charge(params: params.dig(:mandatory_charge))
          country = find_country(params: params.dig(:address, :country))
          address = update_or_create_address(params: params[:address].merge(country: country))
          nexus = update_or_create_nexus(params: params[:nexus].merge(country: country))
          update_or_create_hub(
            params: params[:hub].merge(
              nexus: nexus,
              address: address,
              mandatory_charge: mandatory_charge
            )
          )
        end

        stats
      end

      private

      def find_country(params:)
        Legacy::Country.find_by(params)
      end

      def find_mandatory_charge(params:)
        ::MandatoryCharge.find_by(params)
      end

      def update_or_create_address(params:)
        address = Legacy::Address.find_or_initialize_by(params)
        add_stats(address)
        address.save

        address
      end

      def update_or_create_hub(params:)
        hub = Legacy::Hub.find_or_initialize_by(params.slice(:name, :hub_code, :tenant_id))
        hub.assign_attributes(params)
        add_stats(hub)
        hub.save

        hub
      end

      def update_or_create_nexus(params:)
        nexus = Legacy::Nexus.find_or_initialize_by(params.slice(:name, :locode, :tenant_id))
        nexus.assign_attributes(params)
        add_stats(nexus)
        nexus.save

        nexus
      end
    end
  end
end
