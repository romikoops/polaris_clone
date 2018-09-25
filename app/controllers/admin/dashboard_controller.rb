# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminBaseController
  include ItineraryTools
  before_action :initialize_variables, only: :index

  def index
    response_handler(
      itineraries: @detailed_itineraries,
      hubs:        @hubs,
      shipments:   shipments_hash,
      mapData:     @map_data
    )
  end

  private

  def initialize_variables
    @shipments = Shipment.where(tenant_id: current_user.tenant_id)
    @requested_shipments = requested_shipments
    @open_shipments = open_shipments
    @rejected_shipments = rejected_shipments
    @quoted_shipments = quoted_shipments
    @finished_shipments = finished_shipments
    @detailed_itineraries = detailed_itin_json
    hubs = current_user.tenant.hubs
    @hubs = hubs.limit(8).map do |hub|
      { data: hub, location: hub.location.to_custom_hash }
    end
    @map_data = current_user.tenant.map_data
    @tenant = Tenant.find(current_user.tenant_id)
  end

  def shipments_hash
    current_user.tenant.quotation_tool ? 
    {
      quoted:   @quoted_shipments
    } : {
      requested: @requested_shipments,
      open:      @open_shipments,
      rejected:  @rejected_shipments,
      finished:  @finished_shipments
    }
  end

  def requested_shipments
    @shipments.requested.order_booking_desc.map(&:with_address_options_json)
  end

  def open_shipments
    @shipments.open.order_booking_desc.map(&:with_address_options_json)
  end

  def rejected_shipments
    @shipments.rejected.order_booking_desc.map(&:with_address_options_json)
  end

  def quoted_shipments
    @shipments.quoted.order_booking_desc.map(&:with_address_options_json)
  end

  def finished_shipments
    @shipments.finished.order_booking_desc.map(&:with_address_options_json)
  end

  def detailed_itin_json
    Itinerary.for_tenant(current_user.tenant_id).limit(40).map(&:as_options_json)
  end

end
