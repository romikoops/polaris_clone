# frozen_string_literal: true

module Notifications
  class FilterBuilder
    attr_reader :results

    def initialize(results:)
      @results = results
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
      @origins ||= Journey::RouteSection.includes(:from).where(result: results)&.pluck("journey_route_points.locode")&.uniq&.compact
    end

    def destinations
      @destinations ||= Journey::RouteSection.includes(:to).where(result: results)&.pluck("journey_route_points.locode")&.uniq&.compact
    end

    def mode_of_transports
      @mode_of_transports ||= Journey::RouteSection.where(result: results).where.not(mode_of_transport: %w[relay carriage])&.pluck(:mode_of_transport)&.uniq
    end

    def groups
      @groups ||= OrganizationManager::GroupsService.new(target: query.client, organization: query.organization).fetch.map(&:name)
    end

    def query
      @query ||= results.first.query
    end
  end
end
