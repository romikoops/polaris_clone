require 'csv'

module RmsExport
  module Parser
    class Routes < RmsExport::Parser::Base
      def initialize(tenant_id:)
        super(tenant_id: tenant_id)
        @book = RmsData::Book.find_by(tenant: @tenant, sheet_type: 'routes')
        @routes = []
        @carriers = []
        @line_services = []
        @route_line_services = []
        @transit_times = []
        @tenant_connections = []
      end

      def perform
        @book.sheets.each do |sheet|
          @sheet = sheet
          @headers = sheet.header_values
          sheet.rows_values.each_with_index do |row, i|
            @route = nil
            next unless i.positive?

            find_route(row: row)
            next unless @route

            handle_line_service(row: row)
            handle_tenant_route_connections(row: row)
          end
        end

        {
          line_services: create_csv_file(data: @line_services.uniq, key: 'line_services'),
          route_line_services: create_csv_file(data: @route_line_services.uniq, key: 'route_line_services'),
          transit_times: create_csv_file(data: @transit_times.uniq, key: 'transit_times'),
          tenant_connections: create_csv_file(data: @tenant_connections.uniq, key: 'tenant_connections')
        }
      end

      def handle_line_service(row:)
        @line_services << {
          name: row[headers.index('SERVICE_LEVEL')],
          category: determine_category(row[headers.index('SERVICE_LEVEL')]),
          carrier_name: row[headers.index('CARRIER')] || 'default'
        }
        @route_line_services << {
          line_service: row[headers.index('SERVICE_LEVEL')],
          carrier_name: row[headers.index('CARRIER')] || 'default',
          mode_of_transport: mode_of_transport_enum(row[headers.index('MOT')]),
          origin_name: row[headers.index('ORIGIN')],
          destination_name: row[headers.index('DESTINATION')]
        }
        @transit_times << {
          line_service: row[headers.index('SERVICE_LEVEL')],
          carrier_name: row[headers.index('CARRIER')] || 'default',
          days: row[headers.index('TRANSIT_TIME')],
          origin_name: row[headers.index('ORIGIN')],
          destination_name: row[headers.index('DESTINATION')]
        }
      end

      def handle_tenant_route_connections(row:)
        @tenant_connections << {
          inbound_id: @route.id,
          outbound_id: @route.id,
          tenant_id: @tenant.id
        }
      end

      def find_route(row:)
        origin = ::Routing::Location.where.not(locode: nil).find_by(name: row[headers.index('ORIGIN')])
        destination = ::Routing::Location.where.not(locode: nil).find_by(name: row[headers.index('DESTINATION')])
        if origin.present? && destination.present?
          @route = ::Routing::Route.find_or_create_by(
            origin: origin,
            destination: destination,
            mode_of_transport: mode_of_transport_enum(row[headers.index('MOT')]),
            allowed_cargo: allowed_cargo_bitwise(row: row, headers: headers)
          )
          unless @route.time_factor
            @route.time_factor = time_factor(row[headers.index('MOT')], row[headers.index('SERVICE_LEVEL')])
          end
          unless @route.price_factor
            @route.price_factor = price_factor(row[headers.index('MOT')], row[headers.index('SERVICE_LEVEL')])
          end
          @route.save
        end
      end
      attr_reader :sheet, :row, :headers, :carrier, :line_service, :route
    end
  end
end
