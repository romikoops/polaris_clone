module ExcelTool
  class PortsUploader < ExcelTool::BaseTool
    attr_reader :first_sheet, :country, :nexus, :user, :port_row, :location, :mandatory_charge

    def post_initialize(args)
      @first_sheet = xlsx.sheet(xlsx.sheets.first)
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

      def port_rows
        @port_rows ||= first_sheet.parse(
          name: "Port",
          code: "CODE",
          lat_lng: "Lat/Long Decimal",
          country: "Country",
          phone: "Telephone",
          web: "Web"
        )
      end

      def _nexus
        Location.find_by(
          name: port_row[:name],
          location_type: "nexus",
          country: country
        )
      end

      def _nexus_create
        lat, lng = port_row[:lat_lng].split(', ')
        Location.create!(
          name:             port_row[:name],
          location_type:    "nexus",
          latitude:         lat,
          longitude:        lng,
          photo:            port_row[:photo],
          country:          country,
          city:             port_row[:name],
          geocoded_address: port_row[:geocoded_address]
        )
      end

      def find_or_create_location
        lat, lng = port_row[:lat_lng].split(', ')
        Location.find_or_create_by(
          name:             port_row[:name],
          latitude:         lat,
          longitude:        lng,
          country:          country,
          city:             port_row[:name],
          geocoded_address: port_row[:geocoded_address],
          location_type: nil
        )
      end

      def hub
        @port = Port.find_by(
          nexus_id:  nexus.id,
          name: port_row[:name]
        )
      end

      def update_port
        lat, lng = port_row[:lat_lng].split(', ')
        @port.update_attributes(
          nexus_id:         nexus.id,
          location_id:      location.id,
          latitude:         lat,
          longitude:        lng,
          name:             port_row[:name],
          code:             port_row[:code].gsub!(' ',''),
          web:              port_row[:web],
          telephone:            port_row[:phone],
          country:          @country
        )
      end

      def create_nexus_port
        lat, lng = port_row[:lat_lng].split(', ')
        nexus.ports.create!(
          nexus_id:         nexus.id,
          location_id:      location.id,
          latitude:         lat,
          longitude:        lng,
          name:             port_row[:name],
          code:             port_row[:code].gsub!(' ',''),
          web:              port_row[:web],
          telephone:            port_row[:phone],
          country:          @country
        )
      end

      def update_or_create_hub
        if hub
          update_port
          results[:ports] << hub
          stats[:ports][:number_updated] += 1
        else
          @port = create_nexus_port
          results[:ports] << hub
          stats[:ports][:number_created] += 1
        end
      end

      def update_location_geocode
        if !location.street_number
          location.reverse_geocode
          location.save!
        end
      end

      def geoplace
        return @geoplace if @geoplace
        country_names = port_rows.map { |hub| hub[:country] }.uniq
        @geoplace =  Country.geo_find_by_names(country_names)
      end

      def country_by_code(name)
        code = geoplace.select{ |geo| geo.name == name }&.first&.code
        Country.find_by(code: code)
      end
      def overwrite_ports

        port_rows.map do |_port_row|
          @port_row = _port_row
          @country = country_by_code(port_row[:country])
          next if !@country
          @nexus = _nexus
          @nexus ||= _nexus_create

          @location = find_or_create_location
          update_location_geocode
          update_or_create_hub
          results[:nexuses] << nexus
          stats[:nexuses][:number_updated] += 1
          hub
        end
        { stats: stats, results: results }
      end
  end
end
