# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserter
    class Pricing < Base
      def perform
        data.each do |single_data|
          row = ExcelDataServices::Row.get(klass_identifier).new(row_data: single_data, tenant: tenant)
          itinerary = find_or_initialize_itinerary(row)
          add_stats(:itineraries, itinerary)
          stops = find_or_initialize_stops(row.stop_names, itinerary)
          itinerary.stops << stops
          itinerary.save!

          tenant_vehicle = find_or_create_tenant_vehicle(row)
          generate_trips(itinerary, row, tenant_vehicle) if should_generate_trips?
          create_pricing_with_pricing_details(row, tenant_vehicle, itinerary)
        end

        stats
      end

      private

      def should_generate_trips?
        @should_generate_trips ||= options[:should_generate_trips] || false
      end

      def find_or_initialize_itinerary(row)
        Itinerary.find_or_initialize_by(
          tenant: tenant,
          name: row.itinerary_name,
          mode_of_transport: row.mot
        )
      end

      def find_or_initialize_stops(stop_names, itinerary)
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

      def find_or_create_tenant_vehicle(row)
        carrier = Carrier.find_or_create_by(name: row.carrier) unless row.carrier.blank?

        tenant_vehicle = TenantVehicle.find_by(
          tenant: tenant,
          name: row.service_level,
          mode_of_transport: row.mot,
          carrier: carrier
        )

        # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
        tenant_vehicle || Vehicle.create_from_name(
          row.service_level,
          row.mot,
          tenant.id,
          carrier&.name
        ) # returns a `TenantVehicle`!
      end

      def generate_trips(itinerary, row, tenant_vehicle)
        transit_time = row.transit_time ? row.transit_time.to_i : 30
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

      def create_pricing_with_pricing_details(row, tenant_vehicle, itinerary) # rubocop:disable Metrics/AbcSize
        pricing_params =
          { uuid: row.uuid,
            transport_category: find_transport_category(tenant_vehicle, row.load_type),
            tenant_vehicle: tenant_vehicle,
            tenant: tenant,
            user: User.find_by(tenant_id: tenant.id, email: row.customer_email),
            wm_rate: 1000,
            effective_date: Date.parse(row.effective_date.to_s),
            expiration_date: Date.parse(row.expiration_date.to_s) }

        pricing_to_update =
          itinerary.pricings.find_by(uuid: row.uuid) || itinerary.pricings.find_or_initialize_by(pricing_params)
        add_stats(:pricings, pricing_to_update)
        pricing_to_update.save!

        pricing_detail_params_arr = build_pricing_detail_params_for_pricing(row)

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

      def find_transport_category(tenant_vehicle, cargo_class)
        # TODO: what is called 'load_type' in the excel file is actually a cargo_class!
        @transport_category =
          tenant_vehicle.vehicle.transport_categories.find_by(
            name: 'any',
            cargo_class: cargo_class.downcase
          )
      end

      def build_pricing_detail_params_for_pricing(row)
        case row.data_extraction_method
        when 'dynamic_fee_cols_no_ranges'
          pricing_detail_params_by_dynamic_fee_cols_no_ranges(row)
        when 'one_col_fee_and_ranges'
          pricing_detail_params_by_one_col_fee_and_ranges(row)
        end
      end

      def pricing_detail_params_by_dynamic_fee_cols_no_ranges(row)
        params = row[:fees].map do |fee_code, fee_value|
          next unless fee_value

          ChargeCategory.from_code(fee_code, tenant.id)

          { range: nil,
            rate_basis: row.rate_basis,
            rate: fee_value,
            min: fee_value,
            shipping_type: fee_code.upcase,
            currency_name: row.currency.upcase,
            tenant_id: tenant.id }
        end

        params.compact
      end

      def pricing_detail_params_by_one_col_fee_and_ranges(row) # rubocop:disable Metrics/AbcSize
        fee_code = row.fee_code.upcase

        ChargeCategory.find_or_create_by!(
          code: fee_code,
          name: row.fee_name || fee_code,
          tenant_id: tenant.id
        )

        pricing_detail_params =
          { rate_basis: row.rate_basis,
            shipping_type: fee_code,
            currency_name: row.currency.upcase,
            tenant_id: tenant.id }

        if row.range
          min_rate_in_range = row.range.map { |r| r['rate'] }.min
          min_rate = row.fee_min.blank? ? min_rate_in_range : row.fee_min
          pricing_detail_params.merge!(
            rate: min_rate_in_range,
            min: min_rate,
            range: row.range.blank? ? nil : row.range
          )
        else
          pricing_detail_params[:rate] = row.fee
          pricing_detail_params[:min] = row.fee_min.blank? ? row.fee : row.fee_min
        end
        [pricing_detail_params]
      end
    end
  end
end
