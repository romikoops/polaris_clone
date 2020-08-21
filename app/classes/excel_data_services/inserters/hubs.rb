# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Hubs < ExcelDataServices::Inserters::Base
      NEXUS_ATTRIBUTES = %i[
        name
        latitude
        longitude
        photo
        locode
        country
        organization_id
      ].freeze

      HUB_ATTRIBUTES = %i[
        hub_type
        latitude
        longitude
        hub_code
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
          nexus = update_or_create_port_of_call(params: params[:nexus].merge(country: country), type: :nexus)
          update_or_create_port_of_call(
            params: params[:hub].merge(
              nexus: nexus,
              address: address,
              mandatory_charge: mandatory_charge
            ),
            type: :hub
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

      def update_or_create_port_of_call(params:, type:)
        association, code_key = association_and_locode_key(type: type, mot: params[:hub_type])
        assocation = association.where(params.slice(:organization_id))
        terminal = params[:terminal]
        name_without_terminal = params[:name]

        if terminal.present?
          name = "#{name_without_terminal} - #{terminal}"
          port_of_call = association.find_by(name: name)
        else
          name = name_without_terminal
        end

        port_of_call ||= assocation.find_by(params.slice(code_key)) ||
          assocation.find_by(params.slice(:name)) ||
          assocation.new(name: name)
        port_of_call.assign_attributes(params.slice(*attributes_for(type: type)))
        add_stats(port_of_call, params[:row_nr])
        port_of_call.save

        port_of_call
      end

      def association_and_locode_key(type:, mot:)
        type == :nexus ? [Legacy::Nexus, :locode] : [Legacy::Hub.where(hub_type: mot), :hub_code]
      end

      def attributes_for(type:)
        case type
        when :hub
          HUB_ATTRIBUTES
        when :nexus
          NEXUS_ATTRIBUTES
        end
      end
    end
  end
end
