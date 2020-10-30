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
      return Legacy::Itinerary.none unless origin.present? || destination.present?

      itineraries = Legacy::Itinerary.where(organization: organization)
      itineraries = itineraries.where(origin_hub: hubs_from_target(target: origin)) if origin.present?
      itineraries = itineraries.where(destination_hub: hubs_from_target(target: destination)) if destination.present?
      itineraries
    end

    private

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
        lat_lng_string: [latitude, longitude].join(','),
        get_zip_code: address.postal_code,
        city_name: address.city,
        country: Legacy::Country.find_by(code: address.country_code)
      )
    end

    def user_groups
      @user_groups ||= OrganizationManager::GroupsService.new(
        target: user, organization: organization
      ).fetch
    end
  end
end
