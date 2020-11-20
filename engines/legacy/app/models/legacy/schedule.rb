# frozen_string_literal: true

module Legacy
  class Schedule
    include ActiveModel::Model

    attr_accessor :id, :origin_hub_id, :destination_hub_id,
      :origin_hub_name, :destination_hub_name, :mode_of_transport,
      :total_price, :eta, :etd, :closing_date, :vehicle_name, :trip_id,
      :quote, :carrier_name, :load_type

    def origin_hub
      Hub.find origin_hub_id
    end

    def destination_hub
      Hub.find destination_hub_id
    end

    def hub_for_carriage(carriage)
      return origin_hub if carriage == "pre"
      return destination_hub if carriage == "on"

      raise ArgumentError, "carriage must be 'pre' or 'on'"
    end

    def trip
      Trip.find trip_id
    end

    def to_detailed_hash
      {
        id: id,
        origin_hub: detailed_hash_hub_data_for(:origin),
        destination_hub: detailed_hash_hub_data_for(:destination),
        mode_of_transport: mode_of_transport,
        total_price: total_price,
        eta: eta,
        etd: etd,
        closing_date: closing_date,
        vehicle_name: vehicle_name,
        carrier_name: carrier_name,
        trip_id: trip_id
      }
    end

    def self.quote_trip_dates
      closing_date = Time.zone.now + 1.day
      start_date = closing_date + 4.days
      end_date = start_date + 26.days

      {
        closing_date: closing_date,
        start_date: start_date,
        end_date: end_date
      }
    end

    def self.from_trip(trip)
      new(
        id: SecureRandom.uuid,
        mode_of_transport: trip.itinerary.mode_of_transport,
        eta: trip.end_date,
        etd: trip.start_date,
        closing_date: trip.closing_date,
        origin_hub_id: trip.itinerary.first_stop.hub.id,
        destination_hub_id: trip.itinerary.last_stop.hub.id,
        origin_hub_name: trip.itinerary.first_stop.hub.name,
        destination_hub_name: trip.itinerary.last_stop.hub.name,
        vehicle_name: trip.tenant_vehicle.name,
        carrier_name: trip.tenant_vehicle&.carrier&.name,
        trip_id: trip.id,
        load_type: trip.load_type
      )
    end

    def self.from_trips(trips)
      trips.map do |trip|
        from_trip(trip).to_detailed_hash
      end
    end

    private

    def detailed_hash_hub_data_for(target)
      %i[id name].each_with_object({}) do |hub_attribute, obj|
        obj[hub_attribute] = send("#{target}_hub_#{hub_attribute}")
      end
    end
  end
end
