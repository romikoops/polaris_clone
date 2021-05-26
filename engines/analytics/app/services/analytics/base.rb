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
      Journey::Query.where(organization: organization)
        .where(created_at: start_date..end_date)
        .where(client: clients)
    end

    def shipment_requests
      Journey::ShipmentRequest
        .joins(result: :query)
        .merge(queries)
        .where(created_at: start_date..end_date)
    end

    def results
      Journey::Result.where(result_set: result_sets)
    end

    def result_sets
      Journey::ResultSet.where(query: queries, status: "completed")
    end

    def requests
      quotation_tool? ? queries : shipment_requests
    end

    def requests_with_profiles
      if quotation_tool?
        queries.joins(profile_join(reference: "journey_queries"))
      else
        shipment_requests.joins(profile_join(reference: "shipments_shipment_requests"))
      end
    end

    def requests_with_companies
      if quotation_tool?
        queries.joins(companies_join(reference: "journey_queries"))
      else
        shipment_requests.joins(companies_join(reference: "shipments_shipment_requests"))
      end
    end

    def result_or_request
      quotation_tool? ? results : shipment_requests
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

    def profile_join(reference:)
      <<~SQL
        INNER JOIN users_clients
          ON #{reference}.client_id = users_clients.id
        INNER JOIN users_client_profiles
          ON users_clients.id = users_client_profiles.user_id
      SQL
    end

    def companies_join(reference:)
      <<~SQL
        INNER JOIN users_clients
          ON #{reference}.client_id = users_clients.id
        INNER JOIN companies_memberships
          ON companies_memberships.member_id = users_clients.id
          AND companies_memberships.member_type = 'Users::Client'
        INNER JOIN companies_companies
          ON companies_memberships.company_id = companies_companies.id
      SQL
    end
  end
end
