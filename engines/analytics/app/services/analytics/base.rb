# frozen_string_literal: true

module Analytics
  class Base
    def initialize(user:, organization:, start_date: 30.days.ago, end_date: DateTime.now)
      @user = user
      @organization = organization
      @start_date = start_date
      @end_date = end_date
    end

    def queries
      Journey::Query
        .where(organization: organization)
        .where("journey_queries.client_id IS NULL OR journey_queries.client_id IN (?)", clients.select(:id))
        .where(created_at: start_date..end_date)
    end

    def shipment_requests
      Journey::ShipmentRequest
        .joins(result: :query)
        .merge(queries)
        .where(created_at: start_date..end_date)
    end

    def results
      Journey::Result.where(query_id: queries.where(status: "completed"))
    end

    def requests
      quotation_tool? ? queries : shipment_requests
    end

    def requests_with_profiles
      if quotation_tool?
        queries.left_joins(client: :profile)
      else
        shipment_requests.left_joins(result: { query: { client: :profile } })
      end
    end

    def requests_with_companies
      if quotation_tool?
        queries.left_joins(:company)
      else
        shipment_requests.left_joins(result: { query: :company })
      end
    end

    def result_or_request
      quotation_tool? ? results : shipment_requests
    end

    def target_table
      quotation_tool? ? "journey_queries" : "journey_shipment_requests"
    end

    def clients
      @clients ||= Users::Client.where(organization: organization).where.not(email: blacklisted_emails)
    end

    def main_freight_sections
      Journey::RouteSection.where(result: results).where.not(mode_of_transport: %w[relay carriage])
    end

    def main_freight_sections_with_route_points
      main_freight_sections.joins("JOIN journey_route_points from_points ON journey_route_sections.from_id = from_points.id")
        .joins("JOIN journey_route_points to_points ON journey_route_sections.to_id = to_points.id")
    end

    private

    attr_reader :organization, :user, :start_date, :end_date

    def blacklisted_emails
      scope["blacklisted_emails"]
    end

    def quotation_tool?
      @quotation_tool ||= scope["open_quotation_tool"] || scope["closed_quotation_tool"]
    end

    def scope
      @scope ||= ::OrganizationManager::ScopeService.new(
        target: user,
        organization: organization
      ).fetch
    end
  end
end
