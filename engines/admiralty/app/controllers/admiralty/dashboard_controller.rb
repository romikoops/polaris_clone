# frozen_string_literal: true

require_dependency 'admiralty/application_controller'

module Admiralty
  class DashboardController < ApplicationController
    helper_method :booking_slug, :booking_link
    DEFAULT_ITEM_NUMBER = 10

    def index
      item_number = dashboard_params[:item_number] || DEFAULT_ITEM_NUMBER
      @shipments = shipments_from_external_users.last(item_number)
      @quotations = quotations_from_external_users.last(item_number)
    end

    private

    def external_users
      Tenants::User.select(:id)
                   .joins(:legacy)
                   .where(users: { internal: false })
                   .where.not(email: excluded_emails)
    end

    def shipments_from_external_users
      ::Shipments::ShipmentRequest.where(user: external_users)
                                  .order(created_at: :desc)
    end

    def quotations_from_external_users
      ::Quotations::Quotation.joins(:user)
                             .where(users: { internal: false })
                             .where.not(users: { email: excluded_emails })
                             .order(created_at: :desc)
    end

    def booking_slug(booking)
      Tenants::Tenant.find(booking.tenant_id).slug
    end

    def booking_link(booking)
      domain = Tenants::Domain.find_by(tenant_id: booking.tenant_id, default: true)&.domain
      "https://#{domain}" if domain
    end

    def excluded_emails
      Tenants::Tenant.all.flat_map do |tenant|
        Tenants::ScopeService.new(tenant: tenant).fetch('blacklisted_emails')
      end
    end

    def dashboard_params
      params.permit(:item_number)
    end
  end
end
