# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminBaseController
  include ItineraryTools
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
    @shipments = Shipment.where(tenant_id: current_user.tenant_id)
    @requested_shipments = requested_shipments
    @quoted_shipments = quoted_shipments
    @detailed_itineraries = detailed_itin_json
    hubs = current_user.tenant.hubs
    @hubs = hubs.limit(8).map do |hub|
      { data: hub, address: hub.address.to_custom_hash }
    end
    @map_data = current_user.tenant.map_data
    @tenant = Tenant.find(current_user.tenant_id)
  end

  def shipments_hash
    current_user.tenant.quotation_tool? ?
    {
      quoted: @quoted_shipments
    } : {
      requested: @requested_shipments
    }
  end

  def requested_shipments
    @shipments.requested.order_booking_desc.limit(DASH_SHIPMENTS).map(&:with_address_index_json)
  end

  def open_shipments
    @shipments.open.order_booking_desc.limit(DASH_SHIPMENTS).map(&:with_address_options_json)
  end

  def quoted_shipments
    @shipments.quoted.order_booking_desc.limit(DASH_SHIPMENTS).map(&:with_address_index_json)
  end

  def detailed_itin_json
    Itinerary.for_tenant(current_user.tenant_id).limit(DASH_ITINERARIES).map(&:as_options_json)
  end
end
