# frozen_string_literal: true

include Translator

module DataInserter
  module PfcNordic
    class HubInserter < DataInserter::BaseInserter
      attr_reader :path, :_user, :hub_data, :existing_hub_data, :data, :hub_type, :hub, :input_language, :checked_hubs, :mandatory_charge, :hubs

      def post_initialize(args)
        @user = args[:_user]
        @hub_type = args[:hub_type]
        @checked_hubs = []
        @hubs = []
        @direction = args[:direction]
      end

      def perform
        insert_hubs
      end

      private

      def _stats
        {
          type: 'hubs',
          ports: {
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
          ports: [],
          nexuses: []
        }
      end

      def find_port_data
        Port.find_by(code: @hub_data[:code]) || geocode_port_data
      end

      def default_mandatory_charge
        if @hub_data[:routing]&.include?('RTM') && @direction == 'import'

          @mandatory_charge = MandatoryCharge.find_by(export_charges: true, import_charges: false, pre_carriage: false, on_carriage: false)
        elsif @hub_data[:country] && ['Japan', 'United States of America', 'USA', 'Usa'].include?(@hub_data[:country]) && @direction == 'export'
          @mandatory_charge = MandatoryCharge.find_by(export_charges: false, import_charges: true, pre_carriage: false, on_carriage: false)
        else
          @mandatory_charge = MandatoryCharge.falsified
        end
        @mandatory_charge
      end

      def find_or_create_hub
        return unless @existing_hub_data
        mandatory_charge = default_mandatory_charge
        temp_hub = @user.tenant.hubs.where(
          name: "#{@existing_hub_data[:name]} #{hub_type_name[@hub_type]}",
          hub_type: @hub_type
        ).first

        @hub = temp_hub || @user.tenant.hubs.find_or_create_by(
          name: "#{@existing_hub_data[:name].strip} #{hub_type_name[@hub_type]}",
          latitude: @existing_hub_data[:latitude],
          longitude: @existing_hub_data[:longitude],
          address: @existing_hub_data[:address],
          nexus: @existing_hub_data[:nexus],
          hub_type: @hub_type,
          hub_code: @existing_hub_data[:code],
          mandatory_charge: mandatory_charge
        )
        if @hub.mandatory_charge_id != mandatory_charge.id
          @hub.mandatory_charge = mandatory_charge
          @hub.save!
        end
        awesome_print @hub.mandatory_charge
        @hubs << { hub: @hub, data: @hub_data }
      end

      def hub_type_name
        @hub_type_name ||= {
          'ocean' => 'Port',
          'air'   => 'Airport',
          'rail'  => 'Railyard',
          'truck' => 'Depot'
        }
      end

      def geocode_port_data
        name = @hub_data[:port]
        country_name = @hub_data[:country]

        return if @checked_hubs.include?(name)
        port_address = Address.geocoded_address("#{name}, #{country_name}")
        puts port_address.city
        port_nexus = Nexus.from_short_name("#{name} ,#{country_name}", @user.tenant_id)
        country = Country.find_by_name(country_name)
        if country.nil?
          string = ''
          if country_name == 'Uk'
            string = 'United Kingdom of Great Britain and Northern Ireland'
          elsif country_name == 'Usa'
            string == 'United States of America'
          end
          country = Country.find_by_name(string)
          country = Country.where('name LIKE ?', "%#{country_name}%").first if country.nil?
        end
        {
          hub_code: @hub_data[:code],
          name: name,
          latitude: port_address.latitude,
          longitude: port_address.longitude,
          address: port_address,
          nexus: port_nexus,
          country_id: country.try(:id)
        }
      end

      def insert_hubs
        @data.each do |hub_data|
          @hub_data = hub_data[:data]
          @existing_hub_data = find_port_data
          find_or_create_hub
        end
        @hubs
      end
    end
  end
end
