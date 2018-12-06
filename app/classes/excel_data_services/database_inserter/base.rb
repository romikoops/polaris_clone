# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class Base
      include DataRestructurer

      private

      attr_reader :options

      public

      attr_reader :tenant, :data

      def initialize(tenant_id:, data:, options: {})
        @tenant = Tenant.find(tenant_id)
        @data = data
        @options = options
      end

      def perform
        raise StandardError, "The data doesn't contain the correct format!" unless data_valid?(@data)

        restructured_data = restructure_data(@data)

        restructured_data.each_with_index do |(k_sheet_name, values), sheet_i|
          data_extraction_method = values[:data_extraction_method]
          values[:rows_data].each_with_index do |row, row_i|
            itinerary = find_or_initialize_itinerary(row)
            stops = find_or_initialize_stops(row, itinerary)
            itinerary.stops << stops
            itinerary.save!

            tenant_vehicle = find_or_create_tenant_vehicle(row)
            generate_trips(itinerary, row, tenant_vehicle) if should_generate_trips?
            create_pricing_with_pricing_details(row, tenant_vehicle, itinerary, data_extraction_method)

            puts "Status: Sheet \"#{k_sheet_name}\" (##{sheet_i + 1}) | Row ##{row_i + 1}"
          end
        end
      end

      private

      def data_valid?(_data)
        true
      end

      def itinerary_name(row)
        [row[:origin], row[:destination]].join(' - ')
      end

      def find_or_initialize_itinerary(row)
        Itinerary.find_or_initialize_by(
          name: itinerary_name(row),
          mode_of_transport: row[:mot],
          tenant: @tenant
        )
      end

      def append_hub_suffix(name, mot)
        name + ' ' + case mot
                     when 'ocean' then 'Port'
                     when 'air'   then 'Airport'
                     when 'rail'  then 'Railyard'
                     when 'truck' then 'Depot'
                     end
      end

      def stop_names(row)
        [row[:origin], row[:destination]]
      end

      def find_or_initialize_stops(row, itinerary)
        stop_names = stop_names(row)
        mot = itinerary.mode_of_transport
        stops_as_hubs_names = stop_names.map { |stop_name| append_hub_suffix(stop_name, mot) }
        stops_as_hubs_names.map.with_index do |hub_name, i|
          hub = @tenant.hubs.find_by(name: hub_name)
          raise StandardError, "Stop (Hub) with name \"#{hub_name}\" not found!" unless hub

          stop = itinerary.stops.find_by(hub_id: hub.id, index: i)
          stop || Stop.new(hub_id: hub.id, index: i)
        end
      end

      def find_or_create_carrier(row)
        Carrier.find_or_create_by(name: row[:carrier])
      end

      def service_level(row)
        row[:service_level] || 'standard'
      end

      def find_or_create_tenant_vehicle(row)
        service_level = service_level(row)
        carrier = find_or_create_carrier(row)
        tenant_vehicle = TenantVehicle.find_by(name: service_level, mode_of_transport: row[:mot], tenant_id: @tenant.id, carrier: carrier)
        # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
        tenant_vehicle || Vehicle.create_from_name(service_level, row[:mot], @tenant.id, carrier.name) # returns a `TenantVehicle`!
      end

      def should_generate_trips?
        @should_generate_trips ||= options[:should_generate_trips] || false
      end

      def generate_trips(itinerary, row, tenant_vehicle)
        transit_time = row[:transit_time] ? row[:transit_time].to_i : 30
        itinerary.generate_weekly_schedules(
          itinerary.stops.order(:index),
          [transit_time],
          DateTime.now,
          DateTime.now + 1.week,
          [2, 5],
          tenant_vehicle.id,
          4
        )
      end

      def pricing_details_with_one_col_fee_and_ranges(row)
        fee_code = row[:fee_code].upcase
        ChargeCategory.find_or_create_by!(code: fee_code, name: row[:fee_name], tenant_id: tenant.id)

        pricing_detail_params = { rate_basis: row[:rate_basis],
                                  shipping_type: fee_code,
                                  currency_name: row[:currency].upcase,
                                  tenant_id: @tenant.id }
        if row.has_key?(:range)
          min_rate_in_range = row[:range].map { |r| r['rate'] }.min
          min_rate = row[:fee_min].blank? ? 1 * min_rate_in_range : row[:fee_min]
          pricing_detail_params.merge!(rate: min_rate_in_range,
                                       min: min_rate,
                                       range: row[:range])
        else
          pricing_detail_params[:rate] = row[:fee]
          pricing_detail_params[:min] = row[:fee_min].blank? ? 1 * row[:fee] : row[:fee_min]
        end
        [pricing_detail_params]
      end

      def find_or_create_pricing_details_for_pricing(pricing, row, _data_extraction_method)
        pricing_detail_params_arr = pricing_details_with_one_col_fee_and_ranges(row)

        pricing_detail_params_arr.each do |pricing_detail_params|
          pricing.pricing_details.find_or_create_by(pricing_detail_params)
        end
      end

      def find_transport_category(tenant_vehicle, cargo_class)
        # TODO: what is called 'load_type' in the excel file is actually a cargo_class!
        @transport_category = tenant_vehicle.vehicle.transport_categories.find_by(name: 'any', cargo_class: cargo_class.downcase)
      end

      def create_pricing_with_pricing_details(row, tenant_vehicle, itinerary, data_extraction_method = nil)
        pricing_params = {
          # TODO: what is called 'load_type' in the excel file is actually a cargo_class!
          transport_category: find_transport_category(tenant_vehicle, row[:load_type]),
          tenant_vehicle: tenant_vehicle,
          tenant: @tenant,
          user: nil,
          wm_rate: 1000,
          effective_date: Date.parse(row[:effective_date].to_s),
          expiration_date: Date.parse(row[:expiration_date].to_s)
        }

        pricing_to_update = itinerary.pricings.find_or_create_by!(pricing_params)
        find_or_create_pricing_details_for_pricing(pricing_to_update, row, data_extraction_method)
      end
    end
  end
end
