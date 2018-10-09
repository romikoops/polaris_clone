# frozen_string_literal: true

module DataInserter
  class BaseInserter
    attr_reader :xlsx, :sheets_data

    def initialize(tenant:, data:)
      @tenant = tenant
      @data = data

      @stats = {}
      post_initialize
    end

    def perform
      raise StandardError, "The data doesn't contain the correct format!" unless valid?(@data)

      @data.each do |row|
        itinerary = find_or_initialize_itinerary(row)
        stops = find_or_initialize_stops(row, itinerary)
        itinerary.stops << stops
        itinerary.save!

        # find_tenant_vehicle

        ########
        #
      end
    end

    def stats
      @stats.merge!(local_stats)
    end

    private

    def post_initialize
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
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

    def find_tenant_vehicle(row)
      service_level = service_level(row)
      carrier = find_or_create_carrier(row)
      vehicle = TenantVehicle.find_by(name: service_level, mode_of_transport: row[:mot], tenant_id: @tenant.id, carrier: carrier)
      vehicle ||= Vehicle.create_from_name(service_level, @rate_hash[:data][:mot], @tenant.id, carrier.name)
      @tenant_vehicle = vehicle
    end

    def local_stats
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end
  end
end
