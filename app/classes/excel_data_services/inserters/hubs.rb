# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Hubs < ExcelDataServices::Inserters::Base
      NEXUS_ATTRIBUTES = %i[
        latitude
        longitude
        photo
        country
        organization_id
      ].freeze

      HUB_ATTRIBUTES = %i[
        latitude
        longitude
        import_charges
        export_charges
        pre_carriage
        on_carriage
        free_out
        nexus
        photo
        address
        mandatory_charge
      ].freeze

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
        add_stats(address, params[:row_nr])
        address.save

        address
      end

      def update_or_create_nexus(params:)
        nexuses = Legacy::Nexus.where(params.slice(:organization_id))
        nexus = nexuses.find_or_initialize_by(params.slice(:locode))
        nexus.assign_attributes(params.slice(*NEXUS_ATTRIBUTES, :name))
        add_stats(nexus, params[:row_nr])
        nexus.save

        nexus
      end

      def update_or_create_hub(params:)
        hubs = Legacy::Hub.where(params.slice(:organization_id))
        terminal = params[:terminal]
        name_without_terminal = params[:name]

        if terminal.present?
          name = "#{name_without_terminal} - #{terminal}"
          hub = hubs.find_or_initialize_by(
            name: name,
            hub_type: params[:hub_type]
          )
          hub.hub_code = params[:hub_code]
        else
          hubs = hubs.where.not("name LIKE '% - %'") # cater for terminal/name hack
          hub = hubs.find_or_initialize_by(params.slice(:hub_code, :hub_type))
          hub.name = name_without_terminal
        end

        hub.assign_attributes(params.slice(*HUB_ATTRIBUTES))
        add_stats(hub, params[:row_nr])
        hub.save

        hub
      end
    end
  end
end
