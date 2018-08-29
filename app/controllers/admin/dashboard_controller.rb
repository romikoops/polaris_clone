# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminBaseController
  include ItineraryTools
  before_action :initialize_variables, only: :index

  def index
    response_handler(
      itineraries: @detailed_itineraries,
      hubs:        @hubs,
      shipments:   {
        requested: @requested_shipments,
        open:      @open_shipments,
        finished:  @finished_shipments
      },
      mapData:     @map_data
    )
  end

  private

  def initialize_variables
    @shipments = Shipment.where(tenant_id: current_user.tenant_id)
    @requested_shipments = requested_shipments
    @open_shipments = open_shipments
    @finished_shipments = finished_shipments
    @detailed_itineraries = detailed_itin_json
    hubs = current_user.tenant.hubs
    @hubs = hubs.limit(8).map do |hub|
      { data: hub, location: hub.location.to_custom_hash }
    end
    @map_data = current_user.tenant.map_data
    @tenant = Tenant.find(current_user.tenant_id)
  end

  def requested_shipments
    @shipments.requested.order_booking_desc.map(&:with_address_options_json)
  end

  def open_shipments
    @shipments.open.order_booking_desc.map(&:with_address_options_json)
  end

  def finished_shipments
    @shipments.finished.order_booking_desc.map(&:with_address_options_json)
  end

  def detailed_itin_json
    Itinerary.for_tenant(current_user.tenant_id).limit(40).map(&:as_options_json)
  end

  def flap_map_schedule_by_mot(mot)
    @tenant.itineraries.where(mode_of_transport: mot).limit(10)
           .flat_map { |it| it.prep_schedules(5) }
  end
end
