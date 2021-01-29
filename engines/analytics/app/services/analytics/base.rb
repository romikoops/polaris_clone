# frozen_string_literal: true

module Analytics
  class Base
    def initialize(user:, organization:, start_date: 30.days.ago, end_date: DateTime.now)
      @user = user
      @organization = organization
      @start_date = start_date
      @end_date = end_date
    end

    def quotations
      Quotations::Quotation.where(organization: organization)
        .where(created_at: start_date..end_date)
        .where(user: clients)
    end

    def shipment_requests
      Shipments::ShipmentRequest
        .where(organization: organization)
        .where(created_at: start_date..end_date)
        .where(user: clients)
    end

    def tenders
      Quotations::Tender.where(quotation: quotations)
    end

    def itineraries
      Legacy::Itinerary.where(organization_id: organization.id)
    end

    def requests
      quotation_tool? ? quotations : shipment_requests
    end

    def requests_with_profiles
      if quotation_tool?
        quotations.joins(profile_join(reference: "quotations_quotations"))
      else
        shipment_requests.joins(profile_join(reference: "shipments_shipment_requests"))
      end
    end

    def requests_with_companies
      if quotation_tool?
        quotations.joins(companies_join(reference: "quotations_quotations"))
      else
        shipment_requests.joins(companies_join(reference: "shipments_shipment_requests"))
      end
    end

    def tender_or_request
      quotation_tool? ? tenders : shipment_requests
    end

    def tender_or_request_with_itinerary
      quotation_tool? ? tenders.joins(:itinerary) : shipment_requests.joins(tender: :itinerary)
    end

    def clients
      @clients ||= Users::Client.where(organization: organization).where.not(email: blacklisted_emails)
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
          ON #{reference}.user_id = users_clients.id
        INNER JOIN users_client_profiles
          ON users_clients.id = users_client_profiles.user_id
      SQL
    end

    def companies_join(reference:)
      <<~SQL
        INNER JOIN users_clients
          ON #{reference}.user_id = users_clients.id
        INNER JOIN companies_memberships
          ON companies_memberships.member_id = users_clients.id
          AND companies_memberships.member_type = 'Users::Client'
        INNER JOIN companies_companies
          ON companies_memberships.company_id = companies_companies.id
      SQL
    end
  end
end
