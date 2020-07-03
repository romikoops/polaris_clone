# frozen_string_literal: true

module Wheelhouse
  class RouteFinderService
    attr_reader :origin, :destination, :organization, :load_type, :user

    def self.routes(organization:, origin:, destination:, user:, load_type:)
      new(organization: organization, origin: origin, destination: destination, user: user, load_type: load_type).routes
    end

    def initialize(organization:, origin:, destination:, user:, load_type:)
      @origin = origin
      @destination = destination
      @organization = organization
      @user = user
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
      Legacy::Itinerary.where(organization_id: organization.id)
    end

    def hubs_from_nexus(target:)
      Legacy::Hub.where(organization_id: organization.id, nexus_id: target[:nexus_id])
    end

    def hubs_from_coordinates(target:)
      carriage = target == origin ? 'pre' : 'on'
      ::Trucking::Queries::Hubs.new(
        organization_id: organization.id,
        address: address(target.slice(:latitude, :longitude)),
        carriage: carriage,
        groups: user_groups,
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

    def user_groups
      companies = Companies::Membership.where(member: user)
      membership_ids = Groups::Membership.where(member: user)
                        .or(Groups::Membership.where(member: companies)).select(:group_id)
    end
  end
end
