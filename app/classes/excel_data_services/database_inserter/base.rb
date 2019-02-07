# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class Base # rubocop:disable Metrics/ClassLength
      InsertionError = Class.new(StandardError)
      InvalidDataExtractionMethodError = Class.new(InsertionError)

      def self.insert(options)
        new(options).perform
      end

      def initialize(tenant:, data:, options: {})
        @tenant = tenant
        @data = data
        @options = options
        @stats = stat_descriptors.each_with_object({}) do |descriptor, hsh|
          hsh[descriptor] = {
            number_updated: 0,
            number_created: 0
          }
        end
      end

      def perform
        data.each_with_index do |(_k_sheet_name, values), _sheet_i|
          data_extraction_method = values[:data_extraction_method]
          values[:rows_data].each_with_index do |row, _row_i|
            itinerary = find_or_initialize_itinerary(itinerary_name(row), row[:mot])
            stops = find_or_initialize_stops(row, itinerary)
            itinerary.stops << stops
            itinerary.save!

            tenant_vehicle = find_or_create_tenant_vehicle(row)
            generate_trips(itinerary, row, tenant_vehicle) if should_generate_trips?
            create_pricing_with_pricing_details(row, tenant_vehicle, itinerary, data_extraction_method)
          end
        end

        stats
      end

      private

      attr_reader :tenant, :data, :options, :stats

      def stat_descriptors
        %i(itineraries
           stops
           pricings
           pricing_details)
      end

      def add_stats(descriptor, data_record)
        if data_record.new_record?
          @stats[descriptor][:number_created] += 1
        else
          @stats[descriptor][:number_updated] += 1
        end
      end

      def itinerary_name(row)
        [row[:origin], row[:destination]].join(' - ')
      end

      def find_or_initialize_itinerary(name, mot)
        itinerary = Itinerary.find_or_initialize_by(
          name: name,
          mode_of_transport: mot,
          tenant: tenant
        )
        add_stats(:itineraries, itinerary)

        itinerary
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
          hub = tenant.hubs.find_by(name: hub_name)
          raise HubNotFoundError, "Stop (Hub) with name \"#{hub_name}\" not found!" unless hub

          stop = itinerary.stops.find_by(hub_id: hub.id, index: i)
          stop ||= Stop.new(hub_id: hub.id, index: i)
          add_stats(:stops, stop)

          stop
        end
      end

      def find_or_create_carrier(row)
        Carrier.find_or_create_by(name: row[:carrier]) unless row[:carrier].nil?
      end

      def service_level(row)
        row[:service_level] || 'standard'
      end

      def find_or_create_tenant_vehicle(row)
        service_level = service_level(row)
        carrier = find_or_create_carrier(row)
        tenant_vehicle = TenantVehicle.find_by(name: service_level,
                                               mode_of_transport: row[:mot],
                                               tenant_id: tenant.id,
                                               carrier: carrier)

        # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
        tenant_vehicle || Vehicle.create_from_name(service_level,
                                                   row[:mot],
                                                   tenant.id,
                                                   carrier&.name) # returns a `TenantVehicle`!
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

      def pricing_detail_params_by_one_col_fee_and_ranges(row) # rubocop:disable Metrics/AbcSize
        fee_code = row[:fee_code].upcase
        ChargeCategory.find_or_create_by!(code: fee_code,
                                          name: row[:fee_name] || fee_code,
                                          tenant_id: tenant.id)

        pricing_detail_params = { rate_basis: row[:rate_basis],
                                  shipping_type: row[:fee_code].upcase,
                                  currency_name: row[:currency].upcase,
                                  tenant_id: tenant.id }
        if row.has_key?(:range)
          min_rate_in_range = row[:range].map { |r| r['rate'] }.min
          min_rate = row[:fee_min].blank? ? min_rate_in_range : row[:fee_min]
          pricing_detail_params.merge!(rate: min_rate_in_range,
                                       min: min_rate,
                                       range: row[:range].blank? ? nil : row[:range])
        else
          pricing_detail_params[:rate] = row[:fee]
          pricing_detail_params[:min] = row[:fee_min].blank? ? row[:fee] : row[:fee_min]
        end
        [pricing_detail_params]
      end

      def build_pricing_detail_params_for_pricing(row, _data_extraction_method)
        # Method shall be overwritten by classes that behave differently based on `data_extraction_method`
        pricing_detail_params_by_one_col_fee_and_ranges(row)
      end

      def find_transport_category(tenant_vehicle, cargo_class)
        # TODO: what is called 'load_type' in the excel file is actually a cargo_class!
        @transport_category =
          tenant_vehicle.vehicle.transport_categories.find_by(name: 'any',
                                                              cargo_class: cargo_class.downcase)
      end

      def create_pricing_with_pricing_details(row, tenant_vehicle, itinerary, data_extraction_method = nil) # rubocop:disable Metrics/AbcSize
        pricing_params = {
          uuid: row[:uuid],
          transport_category: find_transport_category(tenant_vehicle, row[:load_type]),
          tenant_vehicle: tenant_vehicle,
          tenant: tenant,
          user: User.find_by(tenant_id: tenant.id, email: row[:customer_email]),
          wm_rate: 1000,
          effective_date: Date.parse(row[:effective_date].to_s),
          expiration_date: Date.parse(row[:expiration_date].to_s)
        }

        pricing_to_update = itinerary.pricings.find_by(uuid: row[:uuid]) || itinerary.pricings.find_or_initialize_by(pricing_params)
        add_stats(:pricings, pricing_to_update)
        pricing_to_update.save!

        pricing_detail_params_arr = build_pricing_detail_params_for_pricing(row, data_extraction_method)
        existing_pricing_details_ids = pricing_to_update.pricing_details.pluck(:id)
        new_pricing_details_ids = []
        pricing_detail_params_arr.each do |pricing_detail_params|
          pricing_detail = pricing_to_update.pricing_details.find_or_initialize_by(pricing_detail_params)
          add_stats(:pricing_details, pricing_detail)
          pricing_detail.save!
          new_pricing_details_ids << pricing_detail.id
        end
        PricingDetail.where(id: (existing_pricing_details_ids - new_pricing_details_ids)).delete_all
      end
    end
  end
end
