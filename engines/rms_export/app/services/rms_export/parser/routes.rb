require 'csv'

module RmsExport
  module Parser
    class Routes < RmsExport::Parser::Base
      def initialize(tenant_id:)
        super(tenant_id: tenant_id)
        @book = RmsData::Book.find_by(tenant: @tenant, sheet_type: 'routes')
        @carriers = []
        @line_services = []
        @route_line_services = []
        @transit_times = []
        @tenant_routes = []
      end

      def perform
        @book.sheets.each do |sheet|
          @sheet = sheet
          @headers = sheet.headers
          sheet.rows.each_with_index do |row, i|
            @route = nil
            next unless i.positive?

            find_route(row: row)
            next unless @route

            handle_line_service(row: row)
            handle_tenant_routes(row: row)
          end
        end

        {
          line_services: create_csv_file(data: @line_services.uniq, key: 'line_services'),
          route_line_services: create_csv_file(data: @route_line_services.uniq, key: 'route_line_services'),
          transit_times: create_csv_file(data: @transit_times.uniq, key: 'transit_times'),
          tenant_routes: create_csv_file(data: @tenant_routes.uniq, key: 'tenant_routes')
        }
      end

      def handle_line_service(row:)
        @line_services << {
          name: row[headers.index('SERVICE_LEVEL')],
          category: determine_category(row[headers.index('SERVICE_LEVEL')]),
          carrier_name: row[headers.index('CARRIER')]
        }
        @route_line_services << {
          route_id: @route.id, 
          line_service: row[headers.index('SERVICE_LEVEL')],
          carrier_name: row[headers.index('CARRIER')]
        }
        @transit_times << {
          route_id: @route.id, 
          line_service: row[headers.index('SERVICE_LEVEL')],
          carrier_name: row[headers.index('CARRIER')],
          days: row[headers.index('TRANSIT_TIME')]
        }
      end

      def handle_tenant_routes(row:)
        @tenant_routes << {
          route_id: @route.id,
          tenant_id: @tenant.id,
          line_service: row[headers.index('SERVICE_LEVEL')],
          carrier_name: row[headers.index('CARRIER')],
          mode_of_transport: mode_of_transport_enum(row[headers.index('MOT')]),
          time_factor: time_factor(row[headers.index('MOT')], row[headers.index('SERVICE_LEVEL')]),
          price_factor: price_factor(row[headers.index('MOT')], row[headers.index('SERVICE_LEVEL')])
        }
      end

      def find_route(row:)
        origin = ::Routing::Location.where.not(locode: nil).find_by(name: row[headers.index('ORIGIN')])
        destination = ::Routing::Location.where.not(locode: nil).find_by(name: row[headers.index('DESTINATION')])
        if origin.present? && destination.present?
          @route = ::Routing::Route.find_or_create_by(origin: origin, destination: destination)
        end
      end

      def determine_category(service)
        if %w(fastest express).include?(service)
          '1'
        elsif %w(cheapest slowest).include?(service)
          '3'
        else
          '2'
        end
      end

      def mode_of_transport_enum(mot)
        { ocean: 1, air: 2, rail: 3, truck: 4 }[mot&.downcase&.to_sym] || 0
      end
      
      def time_factor(mot, service)
        category = determine_category(service)&.to_i
        case mot.downcase
        when 'ocean'
          [nil, 3, 5, 8][category]
        when 'air'
          [nil, 0.5, 1.5, 3][category]
        when 'rail'
          [nil, 6, 7, 9][category]
        when 'truck'
          [nil, 3, 5, 7][category]
        else
          nil
        end
      end

      def price_factor(mot, service)
        category = determine_category(service)&.to_i
        case mot.downcase
        when 'ocean'
          [nil, 7, 5, 3][category]
        when 'air'
          [nil, 9, 7, 6][category]
        when 'rail'
          [nil, 6, 4, 2][category]
        when 'truck'
          [nil, 6,5,4][category]
        else
          nil
        end
      end

      def create_csv_file(data:, key:)
        return nil if data.empty?
        
        file = Tempfile.new("#{key}.csv")
        CSV.open(file, "wb") do |csv|
          csv << data.first.keys

          data.each do |hash|
            csv << hash.values
          end
        end

        file
      end

      attr_reader :sheet, :row, :headers, :carrier, :line_service, :route
    end
  end
end
