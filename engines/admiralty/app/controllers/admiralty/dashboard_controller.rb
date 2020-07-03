# frozen_string_literal: true

require_dependency 'admiralty/application_controller'

module Admiralty
  class DashboardController < ApplicationController
    helper_method :booking_slug, :booking_link
    DEFAULT_ITEM_NUMBER = 10

    def index
      item_number = dashboard_params[:item_number] || DEFAULT_ITEM_NUMBER
      @shipments = shipments_from_excluded_users.first(item_number)
      @quotations = quotations_from_excluded_users.first(item_number)
    end

    private

    def excluded_users
      Users::User.with_deleted
                 .select(:id)
                 .where(email: excluded_emails)
    end

    def shipments_from_excluded_users
      ::Shipments::ShipmentRequest.includes(:user)
                                  .where.not(user_id: excluded_users.ids, billing: :test)
                                  .order(created_at: :desc)
    end

    def quotations_from_excluded_users
      ::Quotations::Quotation.includes(:user)
                             .where.not(user_id: excluded_users.ids, billing: :test)
                             .order(created_at: :desc)
    end

    def booking_slug(booking)
      Organizations::Organization.find(booking.organization_id).slug
    end

    def booking_link(booking)
      domain = Organizations::Domain.find_by(organization_id: booking.organization_id, default: true)&.domain
      "https://#{domain}" if domain
    end

    def excluded_emails
      Organizations::Organization.all.flat_map do |organization|
        ::OrganizationManager::ScopeService.new(organization: organization).fetch('blacklisted_emails')
      end
    end

    def dashboard_params
      params.permit(:item_number)
    end
  end
end
