# frozen_string_literal: true

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

            handle_routes(row: row)
            handle_line_service(row: row)
            handle_tenant_route_connections(row: row)
          end
        end
        average_routes

        {
          carriers: create_csv_file(data: @carriers.uniq, key: 'carriers'),
          routes: create_csv_file(data: @routes.uniq, key: 'routes'),
          line_services: create_csv_file(data: @line_services.uniq, key: 'line_services'),
          route_line_services: create_csv_file(data: @route_line_services.uniq, key: 'route_line_services'),
          tenant_connections: create_csv_file(data: @tenant_connections.uniq, key: 'tenant_connections')
        }
      end

      def handle_line_service(row:)
        @carriers << {
          name: row[headers.index('CARRIER')] || 'default',
          abbreviated_name: row[headers.index('CARRIER')] || 'default'
        }
        @line_services << {
          name: row[headers.index('SERVICE_LEVEL')],
          category: determine_category(row[headers.index('SERVICE_LEVEL')]),
          carrier_name: row[headers.index('CARRIER')] || 'default'
        }
        @route_line_services << {
          line_service: row[headers.index('SERVICE_LEVEL')],
          carrier_name: row[headers.index('CARRIER')] || 'default',
          mode_of_transport: mode_of_transport_enum(row[headers.index('MOT')]),
          transit_time: row[headers.index('TRANSIT_TIME')],
          origin_name: row[headers.index('ORIGIN')],
          destination_name: row[headers.index('DESTINATION')]
        }
      end

      def handle_tenant_route_connections(row:)
        @tenant_connections << {
          mode_of_transport: mode_of_transport_enum(row[headers.index('MOT')]),
          tenant_id: @tenant.id,
          origin_name: row[headers.index('ORIGIN')],
          destination_name: row[headers.index('DESTINATION')]
        }
      end

      def handle_routes(row:)
        @routes << {
          time_factor: time_factor(row[headers.index('MOT')], row[headers.index('SERVICE_LEVEL')] || 'standard'),
          price_factor: price_factor(row[headers.index('MOT')], row[headers.index('SERVICE_LEVEL')] || 'standard'),
          allowed_cargo: allowed_cargo_bitwise(row: row, headers: @headers),
          mode_of_transport: mode_of_transport_enum(row[headers.index('MOT')]),
          origin_name: row[headers.index('ORIGIN')],
          destination_name: row[headers.index('DESTINATION')]
        }
      end

      def average_routes
        end_result = []
        @routes.uniq.group_by { |g| g.slice(:allowed_cargo, :mode_of_transport, :origin_name, :destination_name) }
               .each do |key, values|
          end_result << {
            time_factor: values.sum { |v| v[:time_factor] }.to_d / values.length,
            price_factor: values.sum { |v| v[:price_factor] }.to_d / values.length
          }.merge(key)
        end
        @routes = end_result
      end
      attr_reader :sheet, :row, :headers, :carrier, :line_service, :route
    end
  end
end
