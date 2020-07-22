# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminBaseController
  before_action :initialize_variables, only: :index

  # Number of shipments to be displayed on dashboard
  DASH_SHIPMENTS = 3

  # Number of itienaries to be displayed on dashboard
  DASH_ITINERARIES = 30

  def index
    response = Rails.cache.fetch("#{@shipments.cache_key}/dashboard_index", expires_in: 12.hours) do
      {
        itineraries: @detailed_itineraries,
        hubs: @hubs,
        shipments: shipments_hash,
        mapData: @map_data
      }
    end
    response_handler(response)
  end

  private

  def initialize_variables
    tenant_shipments = Legacy::Shipment.where(organization: current_organization)
      .joins(:user).where(users_users: { deleted_at: nil })
    @shipments = test_user? ? tenant_shipments : tenant_shipments.excluding_tests
    @requested_shipments = requested_shipments
    @quoted_shipments = quoted_shipments
    @detailed_itineraries = detailed_itin_json
    hubs = Hub.where(organization_id: current_organization.id)
    @hubs = hubs.limit(8).map do |hub|
      { data: Legacy::HubDecorator.new(hub), address: hub.address.to_custom_hash }
    end
    @map_data = MapDatum.where(organization_id: current_organization.id)
  end

  def shipments_hash
    quotation_tool? ?
    {
      quoted: @quoted_shipments
    } : {
      requested: @requested_shipments
    }
  end

  def requested_shipments
    decorate_shipments(shipments: @shipments.requested.order_booking_desc.limit(DASH_SHIPMENTS)).map(&:legacy_index_json)
  end

  def open_shipments
    decorate_shipments(shipments: @shipments.open.order_booking_desc.limit(DASH_SHIPMENTS)).map(&:legacy_index_json)
  end

  def quoted_shipments
    decorate_shipments(shipments: @shipments.quoted.order_booking_desc.limit(DASH_SHIPMENTS)).map(&:legacy_index_json)
  end

  def detailed_itin_json
    Itinerary
      .where(organization: current_organization)
      .limit(DASH_ITINERARIES)
      .map(&:as_options_json)
  end
end
