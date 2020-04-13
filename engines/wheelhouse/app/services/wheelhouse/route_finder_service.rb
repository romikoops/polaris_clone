# frozen_string_literal: true

module Wheelhouse
  class RouteFinderService
    attr_reader :origin, :destination, :tenant, :load_type, :user

    def self.routes(origin:, destination:, user:, load_type:)
      new(origin: origin, destination: destination, user: user, load_type: load_type).routes
    end

    def initialize(origin:, destination:, user:, load_type:)
      @origin = origin
      @destination = destination
      @user = user
      @tenant = user.tenant
      @load_type = load_type
    end

    def routes
      itineraries.where(stops: stops)
    end

    private

    def stops
      stops_from_target(target: origin).or(stops_from_target(target: destination))
    end

    def stops_from_target(target:)
      Legacy::Stop.where(
        hub: hubs_from_target(target: target),
        index: target == origin ? 0 : 1
      )
    end

    def hubs_from_target(target:)
      return [] if target.blank?

      if target[:nexus_id]
        hubs_from_nexus(target: target)
      elsif target[:latitude] && target[:longitude]
        hubs_from_coordinates(target: target)
      end
    end

    def itineraries
      Legacy::Itinerary.where(tenant_id: tenant.legacy_id)
    end

    def hubs_from_nexus(target:)
      Legacy::Hub.where(tenant_id: tenant.legacy_id, nexus_id: target[:nexus_id])
    end

    def hubs_from_coordinates(target:)
      carriage = target == origin ? 'pre' : 'on'
      ::Trucking::Queries::Hubs.new(
        tenant_id: tenant.legacy_id,
        address: address(target.slice(:latitude, :longitude)),
        carriage: carriage,
        groups: user.all_groups,
        load_type: load_type
      ).perform
    end

    def address(latitude:, longitude:)
      address = Geocoder.search([latitude.to_f, longitude.to_f]).first
      return unless address

      OpenStruct.new(
        latitude: latitude.to_f,
        longitude: longitude.to_f,
        get_zip_code: address.postal_code,
        city_name: address.city,
        country: OpenStruct.new(code: address.country_code)
      )
    end
  end
end
