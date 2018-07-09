module DataInserter
  class HubInserter < DataInserter::BaseInserter
    attr_reader :path, :user, :hub_data, :existing_hub_data

    def post_initialize(args)
      
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
        byebug
        port = Port.where(code: @hub_data[:code]).first
        if port
          return port
        else
          return geocode_port_data
        end
      end

      def find_or_create_hub
        byebug
      end

      def geocode_port_data
        port_location = Location.geocoded_location("#{@hub_data[:name]}, #{@hub_data[:country]}")
        port_nexus = Location.from_short_name("#{@hub_data[:name]} ,#{@hub_data[:country]}", 'nexus')
        return {
          hub_code: @hub_data[:code],
          name: port_location.city,
          latitude: port_location.latitude,
          longitude: port_location.longitude,
          location: port_location,
          nexus: port_nexus,
          country_id: port_location.country_id
        }
      end


      def insert_hubs
        @data.each do |hub_data|
          @hub_data = hub_data
          @existing_hub_data = find_port_data
          find_or_create_hub
        end
      end
  end
end
