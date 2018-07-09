module DataParser
  class HubParser < DataParser::BaseParser
    attr_reader :path, :user, :port_object

    def post_initialize(args)
      @sheet = @xlsx.sheet(@xlsx.sheets.first)
    end

    def perform
      parse_hubs
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

      # def find_port_data(country_key, port_object)
      #   port = Port.where(code: port_object[:code]).first
      #   if port
      #     return port
      #   else
      #     return geocode_port_data(country_key, port_object)
      #   end
      # end

      # def find_or_create_hub
      # #   byebug
      # # end

      # def geocode_port_data(country_key, port_object)
      #   port_location = Location.geocoded_location("#{port_object[:name]}, #{country_key}")
      #   port_nexus = Location.from_short_name("#{port_object[:name]} ,#{country_key}", 'nexus')
      #   return {
      #     hub_code: port_object[:code],
      #     name: port_location.city,
      #     latitude: port_location.latitude,
      #     longitude: port_location.longitude,
      #     location: port_location,
      #     nexus: port_nexus,
      #     country_id: port_location.country_id
      #   }
      # end

      def get_country(row_index)
        # Look one row above current one for country name.
        @sheet.row(row_index - 1).first
      end
    
      def row_to_hash(row_index, country)
        {
          port:     @sheet.cell("B", row_index),
          code:     @sheet.cell("D", row_index),
          country:  country
        }
      end

      def parse_hubs
        @sheet.each_with_index do |_row, i|
          row_index = i + 1
    
          # "Hafen" is unique anchor that differentiates the data
          # of the individual countries.
          next unless @sheet.cell("B", row_index) == "Hafen"
    
          country = get_country(row_index)
          row_hashes = []
    
          # Look one row after the current one for actual data rows.
          # Stop iterating when no valid float value for the "Rate" column is found.
          row_index += 1
          row_hash = row_to_hash(row_index, country)
          while !row_hash[:code].nil?
            row_hashes << row_hash
            row_index += 1
            row_hash = row_to_hash(row_index, country)
          end
          awesome_print row_hashes
          row_hashes
        end
      end
  end
end
