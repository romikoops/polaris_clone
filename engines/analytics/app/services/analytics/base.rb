# frozen_string_literal: true

module Analytics
  class Base
    def initialize(user:, start_date: 30.days.ago, end_date: DateTime.now, sandbox: nil)
      @user = user
      @tenant = user.tenant
      @start_date = start_date
      @end_date = end_date
      @sandbox = sandbox
    end

    def quotations
      Quotations::Quotation.where(tenant: tenant).where(created_at: start_date..end_date)
    end

    def shipment_requests
      Shipments::ShipmentRequest.where(tenant: tenant).where(created_at: start_date..end_date)
    end

    def tenders
      Quotations::Tender.where(quotation: quotations)
    end

    def itineraries
      Legacy::Itinerary.where(tenant_id: tenant.legacy_id, sandbox: sandbox)
    end

    def requests
      quotation_tool? ? quotations : shipment_requests
    end

    def requests_with_profiles
      quotation_tool? ? quotations.joins(tenants_user: :profile) : shipment_requests.joins(user: :profile)
    end

    def requests_with_companies
      quotation_tool? ? quotations.joins(tenants_user: :company) : shipment_requests.joins(user: :company)
    end

    def tender_or_request
      quotation_tool? ? tenders : shipment_requests
    end

    def tender_or_request_with_itinerary
      quotation_tool? ? tenders.joins(:itinerary) : shipment_requests.joins(tender: :itinerary)
    end

    def legacy_clients
      @legacy_clients ||= Legacy::User.where(tenant_id: tenant.legacy_id).where.not(role: admin_roles)
    end

    def clients
      @clients ||= Tenants::User.where(legacy: legacy_clients)
    end

    private

    attr_reader :tenant, :user, :sandbox, :start_date, :end_date

    def admin_roles
      Legacy::Role.where(name: %w[admin sub_admin super_admin])
    end

    def quotation_tool?
      scope['open_quotation_tool'] || scope['closed_quotation_tool']
    end

    def scope
      @scope ||= ::Tenants::ScopeService.new(
        target: user,
        tenant: tenant
      ).fetch
    end
  end
end
