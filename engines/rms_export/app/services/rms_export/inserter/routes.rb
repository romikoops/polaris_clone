# frozen_string_literal: true

require 'csv'

module RmsExport
  module Inserter
    class Routes < RmsExport::Inserter::Base
      def perform
        @data.each do |key, file|
          send("insert_#{key}", file) if file
        end
      end

      def insert_line_services(file)
        Routing::LineService.connection.execute <<-SQL
          DROP TABLE IF EXISTS line_service_imports;
          CREATE TEMP TABLE line_service_imports
          (
            name character varying,
            category bigint,
            carrier_name character varying
          )
        SQL
        File.open(file, 'r') do |file|
          Routing::LineService.connection.raw_connection.copy_data %(copy line_service_imports from stdin with csv delimiter ',' quote '"' ) do
            while line = file.gets
              next if line == "name,category,carrier_name\n"

              Routing::LineService.connection.raw_connection.put_copy_data line

            end
          end
        end

        Routing::LineService.connection.execute <<-SQL
          insert into routing_line_services(
            name,
            carrier_id,
            category,
            created_at,
            updated_at
          )
          select
            li.name,
            c.id,
            li.category,
            current_timestamp,
            current_timestamp
          from line_service_imports li
          left join routing_carriers c on c.abbreviated_name = li.carrier_name
          on conflict do nothing
        SQL
      end

      def insert_route_line_services(file)
        Routing::LineService.connection.execute <<-SQL
            DROP TABLE IF EXISTS route_line_service_imports;
            CREATE TEMP TABLE route_line_service_imports
            (
              route_id uuid,
              service_level character varying,
              carrier_name character varying
            )
        SQL
        File.open(file, 'r') do |file|
          Routing::LineService.connection.raw_connection.copy_data %(copy route_line_service_imports from stdin with csv delimiter ',' quote '"' ) do
            while line = file.gets
              next if line == "route_id,line_service,carrier_name\n"

              Routing::LineService.connection.raw_connection.put_copy_data line

            end
          end
        end

        Routing::LineService.connection.execute <<-SQL
            insert into routing_route_line_services(
              route_id,
              line_service_id,
              created_at,
              updated_at
            )
            select
              li.route_id,
              ls.id,
              current_timestamp,
              current_timestamp
            from route_line_service_imports li
            left join routing_carriers c on c.abbreviated_name = li.carrier_name
            left join routing_line_services ls on ls.name = li.service_level and ls.carrier_id = c.id
            on conflict do nothing
        SQL
      end

      def insert_transit_times(file)
        Routing::TransitTime.connection.execute <<-SQL
          DROP TABLE IF EXISTS transit_time_imports;
          CREATE TEMP TABLE transit_time_imports
          (
            route_id uuid,
            service_level character varying,
            carrier_name character varying,
            days decimal
          )
        SQL
        File.open(file, 'r') do |file|
          Routing::TransitTime.connection.raw_connection.copy_data %(copy transit_time_imports from stdin with csv delimiter ',' quote '"' ) do
            while line = file.gets
              next if line == "route_id,line_service,carrier_name,days\n"

              Routing::TransitTime.connection.raw_connection.put_copy_data line

            end
          end
        end

        Routing::TransitTime.connection.execute <<-SQL
          insert into routing_transit_times(
            route_line_service_id,
            days,
            created_at,
            updated_at
          )
          select
            rls.id,
            li.days,
            current_timestamp,
            current_timestamp
          from transit_time_imports li
          left join routing_carriers c on c.abbreviated_name = li.carrier_name
          left join routing_line_services ls on ls.name = li.service_level and ls.carrier_id = c.id
          left join routing_route_line_services rls on rls.route_id = li.route_id and rls.line_service_id = ls.id
          on conflict do nothing
        SQL
      end

      def insert_tenant_routes(file)
        TenantRouting::Route.connection.execute <<-SQL
          DROP TABLE IF EXISTS tenant_route_imports;
          CREATE TEMP TABLE tenant_route_imports
          (
            route_id uuid,
            tenant_id uuid,
            service_level character varying,
            carrier_name character varying,
            mode_of_transport bigint,
            time_factor decimal,
            price_factor decimal
          )
        SQL
        File.open(file, 'r') do |file|
          TenantRouting::Route.connection.raw_connection.copy_data %(copy tenant_route_imports from stdin with csv delimiter ',' quote '"' ) do
            while line = file.gets
              next if line == "route_id,tenant_id,line_service,carrier_name,mode_of_transport,time_factor,price_factor\n"

              TenantRouting::Route.connection.raw_connection.put_copy_data line

            end
          end
        end

        TenantRouting::Route.connection.execute <<-SQL
          insert into tenant_routing_routes(
            route_id,
            line_service_id,
            mode_of_transport,
            time_factor,
            price_factor,
            created_at,
            updated_at
          )
          select
            li.route_id,
            ls.id,
            li.mode_of_transport,
            li.time_factor,
            li.price_factor,
            current_timestamp,
            current_timestamp
          from tenant_route_imports li
          left join routing_carriers c on c.abbreviated_name = li.carrier_name
          left join routing_line_services ls on ls.name = li.service_level and ls.carrier_id = c.id
          on conflict do nothing
        SQL
      end
      # reload!; t_id = Tenants::Tenant.find_by(subdomain: 'demo').id; y = RmsExport::Parser::Routes.new(tenant_id: t_id).perform; x = RmsExport::Inserter::Routes.new(tenant_id: t_id, data: y).perform
      attr_reader :sheet, :row, :headers, :carrier, :line_service, :route
    end
  end
end
