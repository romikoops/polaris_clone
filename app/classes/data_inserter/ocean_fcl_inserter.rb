# frozen_string_literal: true

module DataInserter
  class OceanFclInserter < DataInserter::BaseInserter
    def perform(should_generate_trips = false)
      super

      n_rows = @data.length
      @data.each_with_index do |row, i|
        itinerary = find_or_initialize_itinerary(row)
        stops = find_or_initialize_stops(row, itinerary)
        itinerary.stops << stops
        itinerary.save!

        tenant_vehicle = find_or_create_tenant_vehicle(row)
        generate_trips(itinerary, row, tenant_vehicle) if should_generate_trips
        create_pricings(row, tenant_vehicle)

        print_status(i, n_rows)
      end
    end

    private

    def post_initialize
    end

    def valid?(_data)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
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

    def stop_names(row)
      [row[:origin], row[:destination]]
    end

    def find_or_initialize_stops(row, itinerary)
      stop_names(row).map.with_index do |stop_name, i|
        hub = @tenant.hubs.find_by(name: stop_name)
        raise StandardError, "Stop (Hub) with name \"#{stop_name}\" not found!" unless hub

        stop = itinerary.stops.find_by(hub_id: hub.id, index: i)
        stop || Stop.new(hub_id: hub.id, index: i)
      end
    end

    def service_level(row)
      row[:service_level] || 'standard'
    end

    def find_or_create_carrier(row)
      Carrier.find_or_create_by!(name: row[:carrier])
    end

    def find_or_create_tenant_vehicle(row)
      service_level = service_level(row)
      carrier = find_or_create_carrier(row)
      tenant_vehicle = TenantVehicle.find_by(name: service_level, mode_of_transport: row[:mot], tenant_id: @tenant.id, carrier: carrier)
      # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
      tenant_vehicle || Vehicle.create_from_name(service_level, row[:mot], @tenant.id, carrier.name)
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

    def find_transport_category(cargo_class, tenant_vehicle)
      @transport_category = tenant_vehicle.vehicle.transport_categories.find_by(name: 'any', cargo_class: cargo_class)
    end

    def create_pricings(row, tenant_vehicle)
      row[:rate].each do |rate|
        default_pricing_values = {
          transport_category: find_transport_category(rate[:cargo_class], tenant_vehicle),
          tenant: @tenant,
          user: nil,
          wm_rate: 1000,
          effective_date: DateTime.now,
          expiration_date: DateTime.now + 365
        }
        pricing_to_update = @itinerary.pricings.find_or_create_by!(default_pricing_values)
        pricing_details = [rate]

        pricing_details.each do |pricing_detail|
          shipping_type = pricing_detail.delete(:code)
          currency = pricing_detail.delete(:currency)
          pricing_detail.delete(:cargo_class)
          pricing_detail_params = pricing_detail.merge(shipping_type: shipping_type, tenant: @tenant)
          pricing_detail = pricing_to_update.pricing_details.find_or_create_by(shipping_type: shipping_type, tenant: @tenant)
          pricing_detail.update!(pricing_detail_params)
          pricing_detail.update!(currency_name: currency)
        end
      end
    end

    def print_status(_current, total)
      puts "#{i}/#{total}, #{i / total.to_f} %"
    end

    def local_stats
      {}
    end
  end
end
