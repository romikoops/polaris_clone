require 'csv'

module RmsExport
  module Parser
    class Carriage < RmsExport::Parser::Base
      def initialize(tenant_id:)
        super(tenant_id: tenant_id)
        @book = RmsData::Book.find_by(tenant: @tenant, sheet_type: 'carriage')
        @carriers = []
        @routes = []
        @line_services = []
        @route_line_services = []
        @transit_times = []
        @tenant_connections = []
        @targets = {}
      end

      def perform
        @book.sheets.each do |sheet|
          @sheet = sheet
          @metadata = sheet.metadata
          @headers = sheet.headers
          handle_carriers
          handle_hub_columns
          handle_line_service
        end

        {
          carriers: create_csv_file(data: @carriers.uniq, key: 'carriers'),
          line_services: create_csv_file(data: @line_services.uniq, key: 'line_services'),
          route_line_services: create_csv_file(data: @route_line_services.uniq, key: 'route_line_services'),
          routes: create_csv_file(data: @routes.uniq, key: 'routes'),
          transit_times: create_csv_file(data: @transit_times.uniq, key: 'transit_times'),
          tenant_connections: create_csv_file(data: @tenant_connections.uniq, key: 'tenant_connections')         
        }
      end

      def handle_hub_columns
        @sheet.columns.each do |column_data|
          next if column_data.first.column.zero?

          column_data.each do |cell|
            handle_target_ids(cell) if cell.row.zero?
            next if cell.row.zero?
            next unless @hub

            handle_routes(cell)
            handle_connections
          end
        end
      end

      def handle_target_ids(cell)
        @hub = Legacy::Hub.find_by(tenant: @tenant.legacy, name: cell.value)
        @hub_loc = Routing::Location.find_by(name: @hub.nexus.name)
        @origin_ids = Routing::Route.where(origin: hub_loc).ids
        @destination_ids = Routing::Route.where(destination: hub_loc).ids
      end

      def handle_carriers
        if metadata['courier_name'].present?
          @carriers << {
            name: metadata['courier_name'],
            abbreviated_name: metadata['courier_name'],
          }
        end
      end

      def handle_routes(cell)
        [
          {
            origin_name: @hub_loc.name,
            destination_name: @sheet.cell(row: cell.row, column: 0)
          },
          {
            origin_name: @sheet.cell(row: cell.row, column: 0),
            destination_name: @hub_loc.name
          }
        ].each do |loc_info|
          @routes << {
            time_factor: time_factor('carriage', metadata['service_level'] || 'standard'),
            price_factor: price_factor('carriage', metadata['service_level'] || 'standard'),
            allowed_cargo: 3,
            mode_of_transport: 5
          }.merge(loc_info)
          @route_line_services << {
            line_service: metadata['service_level'] || 'standard',
            carrier_name: metadata['courier_name'] || '',
            mode_of_transport: 5
          }.merge(loc_info)
          @transit_times << {
            line_service: metadata['service_level'] || 'standard',
            carrier_name: metadata['courier_name'] || '',
            days: 1
          }.merge(loc_info)
        end
      end

      def handle_connections
        @destination_ids.each do |id|
          @tenant_connections << {
            inbound_id: id,
            outbound_id: nil,
            tenant_id: @tenant.id
          }
        end
        @origin_ids.each do |id|
          @tenant_connections << {
            outbound_id: id,
            inbound_id: nil,
            tenant_id: @tenant.id
          }
        end
      end

      def handle_line_service
        @line_services << {
          name: metadata['service_level'] || 'standard',
          category: determine_category(metadata['service_level'] || 'standard'),
          carrier_name: metadata['courier_name'] || ''
        }
      end

      attr_reader :sheet, :row, :headers, :carrier, :line_service, :route, :metadata, :hub_loc
    end
  end
end
