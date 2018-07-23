module DataParser
  class JsonParser < DataParser::BaseParser
    attr_reader :path, :user, :port_object

    def post_initialize(args)
      # @json_data = JSON.parse(File.read(Rails.root + path))
    end

    def perform
      overwrite_ports
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

      def find_port_data(country_key, port_object)
        port = Port.where(code: port_object[:code]).first
        if port
          return port
        else
          return geocode_port_data(country_key, port_object)
        end
      end

      def find_or_create_hub
        # byebug
      end

      def geocode_port_data(country_key, port_object)
        port_location = Location.geocoded_location("#{port_object[:name]}, #{country_key}")
        port_nexus = Location.from_short_name("#{port_object[:name]} ,#{country_key}", 'nexus')
        return {
          hub_code: port_object[:code],
          name: port_location.city,
          latitude: port_location.latitude,
          longitude: port_location.longitude,
          location: port_location,
          nexus: port_nexus,
          country_id: port_location.country_id
        }
      end
      
      def overwrite_ports

        @json_data.each do |country_key, port_array|
          port_array.each do |port_object|
            port_object.deep_symbolize_keys!
            existing_port_data = find_port_data(country_key, port_object)
            next if !existing_port_data
            find_or_create_hub
          end
        end
        { stats: stats, results: results }
      end
  end
end
