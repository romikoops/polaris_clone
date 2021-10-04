# frozen_string_literal: true

module Notifications
  class FilterBuilder
    attr_reader :offer

    def initialize(offer:)
      @offer = offer
    end

    def to_hash
      {}.tap do |h|
        h[:origins] = origins
        h[:destinations] = destinations
        h[:mode_of_transports] = mode_of_transports
        h[:groups] = groups
      end
    end

    private

    def origins
      @origins ||= Journey::RouteSection.includes(:from).where(result: offer.results)&.pluck("journey_route_points.locode")&.uniq&.compact
    end

    def destinations
      @destinations ||= Journey::RouteSection.includes(:to).where(result: offer.results)&.pluck("journey_route_points.locode")&.uniq&.compact
    end

    def mode_of_transports
      @mode_of_transports ||= Journey::RouteSection.where(result_id: offer.results.ids).where.not(mode_of_transport: %w[relay carriage])&.pluck(:mode_of_transport)&.uniq
    end

    def groups
      @groups ||= OrganizationManager::GroupsService.new(target: offer.query.client, organization: offer.query.organization).fetch.map(&:name)
    end
  end
end
