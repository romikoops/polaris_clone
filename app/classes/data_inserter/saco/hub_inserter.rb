include Translator

module DataInserter
  module Saco
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
            type: "hubs",
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
          
          port = Port.where(code: @hub_data[:code]).first
          if port
            return port
          else
            return geocode_port_data
          end
        end

        def default_mandatory_charge
         
          if @hub_data[:routing] && @hub_data[:routing].include?('RTM') && @direction == 'import'
            
            @mandatory_charge = MandatoryCharge.find_by(export_charges: true, import_charges: false, pre_carriage: false, on_carriage: false)
          else
            @mandatory_charge = MandatoryCharge.falsified
          end
          return @mandatory_charge
        end

        def find_or_create_origin(data)
          data[:itineraries].each do |itinerary_hash|
            @origin = @user.tenant.hubs.find_by(itinerary_hash[:origin])
            @origin ||= @user.tenant.hubs.find_or_create_by(
              name: "#{@existing_hub_data[:name].strip} #{hub_type_name[@hub_type]}",
              latitude: @existing_hub_data[:latitude],
              longitude: @existing_hub_data[:longitude],
              location: @existing_hub_data[:location],
              nexus: @existing_hub_data[:nexus],
              hub_type: @hub_type,
              hub_code: @existing_hub_data[:code],
              mandatory_charge: mandatory_charge
            )
          end
        end

        def find_or_create_hub
          return if !@existing_hub_data
          mandatory_charge = default_mandatory_charge
          temp_hub = @user.tenant.hubs.where(
            name: "#{@existing_hub_data[:name]} #{hub_type_name[@hub_type]}",
            hub_type: @hub_type
          ).first

          @hub = temp_hub || @user.tenant.hubs.find_or_create_by(
            name: "#{@existing_hub_data[:name].strip} #{hub_type_name[@hub_type]}",
            latitude: @existing_hub_data[:latitude],
            longitude: @existing_hub_data[:longitude],
            location: @existing_hub_data[:location],
            nexus: @existing_hub_data[:nexus],
            hub_type: @hub_type,
            hub_code: @existing_hub_data[:code],
            mandatory_charge: mandatory_charge
          )
          if @hub.mandatory_charge_id != mandatory_charge.id
            @hub.mandatory_charge = mandatory_charge
            @hub.save!
          end

          @hubs << {hub: @hub, data: @hub_data}
        end

        def hub_type_name
          @hub_type_name ||= {
            "ocean" => "Port",
            "air"   => "Airport",
            "rail"  => "Railyard",
            "truck" => "Depot"
          }
        end

        def geocode_port_data
          name = @hub_data[:port]
          country_name = @hub_data[:country]
          
          
          return if @checked_hubs.include?(name)
          port_location = Location.geocoded_location("#{name}, #{country_name}")

          port_nexus = Nexus.from_short_name("#{name} ,#{country_name}", @user.tenant_id)
          country = Country.find_by_name(country_name)
          if country.nil?
            country = Country.where("name LIKE ?", "%#{country_name}%").first
          end
          return {
            hub_code: @hub_data[:code],
            name: name,
            latitude: port_location.latitude,
            longitude: port_location.longitude,
            location: port_location,
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
          return @hubs
        end
    end
  end
end
