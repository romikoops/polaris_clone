# frozen_string_literal: true

module RmsExport
  module Inserter
    class Base
      def initialize(tenant_id:, data:)
        @tenant = Tenants::Tenant.find_by(id: tenant_id)
        @data = data
      end

      def perform
        @data.each do |key, file|
          insert(key: key, file: file) if file
        end
      end

      def insert(key:, file:)
        data = query_lookup[key]
        data[:klass].connection.execute <<-SQL
          DROP TABLE IF EXISTS #{data[:import_table]};
          CREATE TEMP TABLE #{data[:import_table]}
          ( #{data[:import_schema]} )
        SQL
        File.open(file, 'r') do |file|
          data[:klass].connection.raw_connection.copy_data %(copy #{data[:import_table]} from stdin with csv delimiter ',' quote '"' ) do
            while line = file.gets

              data[:klass].connection.raw_connection.put_copy_data line

            end
          end
        end
        insert = "insert into #{data[:insert_table]} (
          #{data[:insert_schema]}
          created_at,
          updated_at
        )
        select
          #{data[:insert_select]}
          current_timestamp,
          current_timestamp
        from #{data[:import_table]} li
        #{data[:entry_clauses]}
        on conflict #{data[:on_conflict]}"

        data[:klass].connection.execute(insert)
      end

      def query_lookup
        {
          carriers: {
            klass: Routing::Carrier,
            import_table: 'routing_carrier_imports',
            import_schema: 'name character varying, abbreviated_name character varying',
            insert_table: 'routing_carriers',
            insert_schema: 'name, abbreviated_name,',
            insert_select: 'li.name, li.abbreviated_name,',
            entry_clauses: '',
            on_conflict: 'do nothing'
          },
          line_services: {
            klass: Routing::LineService,
            import_table: 'line_service_imports',
            import_schema: 'name character varying, category bigint, carrier_name character varying',
            insert_table: 'routing_line_services',
            insert_schema: ' name, carrier_id, category,',
            insert_select: 'li.name, c.id, li.category,',
            entry_clauses: 'left join routing_carriers c on c.abbreviated_name = li.carrier_name',
            on_conflict: 'do nothing'
          },
          route_line_services: {
            klass: Routing::RouteLineService,
            import_table: 'route_line_service_imports',
            import_schema: 'service_level character varying, carrier_name character varying, mode_of_transport bigint,
            origin_name character varying, destination_name character varying',
            insert_table: 'routing_route_line_services',
            insert_schema: 'route_id, line_service_id,',
            insert_select: 'r.id, ls.id,',
            entry_clauses: 'left join routing_locations ol on ol.name = li.origin_name
              left join routing_locations dl on dl.name = li.destination_name
              left join routing_routes r on r.origin_id = ol.id and r.destination_id = dl.id and r.mode_of_transport = li.mode_of_transport
              left join routing_carriers c on c.abbreviated_name = li.carrier_name
              left join routing_line_services ls on ls.name = li.service_level and ls.carrier_id = c.id',
            on_conflict: 'do nothing'
          },
          routes: {
            klass: Routing::Route,
            import_table: 'routing_routes_import',
            import_schema: 'time_factor decimal, price_factor decimal, allowed_cargo bigint, mode_of_transport bigint, origin_name character varying, 
            destination_name character varying',
            insert_table: 'routing_routes',
            insert_schema: 'origin_id, destination_id, origin_terminal_id, destination_terminal_id, allowed_cargo, mode_of_transport, time_factor, price_factor,',
            insert_select: 'ol.id, dl.id, otl.id, dtl.id, li.allowed_cargo, li.mode_of_transport, li.time_factor, li.price_factor,',
            entry_clauses: ' left join routing_locations ol on ol.name = li.origin_name
            left join routing_locations dl on dl.name = li.destination_name
            left join routing_terminals otl on otl.location_id = ol.id and otl.mode_of_transport = li.mode_of_transport
            left join routing_terminals dtl on dtl.location_id = dl.id and dtl.mode_of_transport = li.mode_of_transport',
            on_conflict: 'do nothing'
          },
          transit_times: {
            klass: Routing::TransitTime,
            import_table: 'transit_time_imports',
            import_schema: 'service_level character varying, carrier_name character varying, mode_of_transport integer, days decimal,
            origin_name character varying, destination_name character varying',
            insert_table: 'routing_transit_times',
            insert_schema: 'route_line_service_id, days,',
            insert_select: 'rls.id, li.days,',
            entry_clauses: 'left join routing_locations ol on ol.name = li.origin_name
            left join routing_locations dl on dl.name = li.destination_name
            left join routing_terminals otl on otl.location_id = ol.id and otl.mode_of_transport = li.mode_of_transport
            left join routing_terminals dtl on dtl.location_id = dl.id and dtl.mode_of_transport = li.mode_of_transport
            left join routing_routes r on r.origin_id = ol.id and r.destination_id = dl.id and r.origin_terminal_id = otl.id and r.destination_terminal_id = dtl.id
            left join routing_carriers c on c.abbreviated_name = li.carrier_name
            left join routing_line_services ls on ls.name = li.service_level and ls.carrier_id = c.id
            left join routing_route_line_services rls on rls.route_id = r.id and rls.line_service_id = ls.id',
            on_conflict: 'do nothing'
          },
          tenant_connections: {
            klass: TenantRouting::Connection,
            import_table: 'tenant_connection_imports',
            import_schema: 'mode_of_transport bigint, tenant_id uuid, origin_name character varying, 
            destination_name character varying',
            insert_table: 'tenant_routing_connections',
            insert_schema: 'inbound_id, outbound_id, tenant_id,',
            insert_select: 'r.id, r.id, li.tenant_id,',
            entry_clauses: 'left join routing_locations ol on ol.name = li.origin_name
            left join routing_locations dl on dl.name = li.destination_name
            left join routing_terminals otl on otl.location_id = ol.id and otl.mode_of_transport = li.mode_of_transport
            left join routing_terminals dtl on dtl.location_id = dl.id and dtl.mode_of_transport = li.mode_of_transport
            left join routing_routes r on r.origin_id = ol.id and r.destination_id = dl.id and r.origin_terminal_id = otl.id and r.destination_terminal_id = dtl.id',
            on_conflict: 'do nothing'
          },
          tenant_carriage_connections: {
            klass: TenantRouting::Connection,
            import_table: 'tenant_connection_imports',
            import_schema: 'outbound_id uuid, inbound_id uuid, tenant_id uuid',
            insert_table: 'tenant_routing_connections',
            insert_schema: 'inbound_id, outbound_id, tenant_id,',
            insert_select: 'li.inbound_id, li.outbound_id, li.tenant_id,',
            entry_clauses: '',
            on_conflict: 'do nothing'
          }
        }.with_indifferent_access
      end
    end
  end
end
