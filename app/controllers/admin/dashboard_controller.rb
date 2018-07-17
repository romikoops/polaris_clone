# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminBaseController
  include ItineraryTools
  before_action :initialize_variables, only: :index

  def index
    response_handler(air: @air_schedules,
      train: @train_schedules,
      ocean: @ocean_schedules,
      itineraries: @detailed_itineraries,
      hubs: @hubs,
      shipments: {
        requested: @requested_shipments,
        open: @open_shipments,
        finished: @finished_shipments
      })
  end

  private

  def initialize_variables
    @shipments = Shipment.where(tenant_id: current_user.tenant_id)
    @requested_shipments = requested_shipments
    @open_shipments = open_shipments
    @finished_shipments = finished_shipments
    @detailed_itineraries = detailed_itin_json
    @hubs = Hub.prepped(current_user)
    @tenant = Tenant.find(current_user.tenant_id)
    @train_schedules = flap_map_schedule_by_mot("rail")
    @ocean_schedules = flap_map_schedule_by_mot("ocean")
    @air_schedules = flap_map_schedule_by_mot("air")
  end

  def requested_shipments
    @shipments.requested.order_booking_desc.map do |shipment|
      shipment.with_address_options_json
    end
  end

  def open_shipments
    @shipments.open.order_booking_desc.map do |shipment|
      shipment.with_address_options_json
    end
  end

  def finished_shipments
    @shipments.finished.order_booking_desc.map do |shipment|
      shipment.with_address_options_json
    end
  end


  def detailed_itin_json
    Itinerary.for_tenant(current_user.tenant_id).map do |itinerary|
      itinerary.as_options_json(methods: :routes)
    end
  end

  def flap_map_schedule_by_mot(mot)
    @tenant.itineraries.where(mode_of_transport: mot).limit(10)
      .flat_map { |it| it.prep_schedules(5) }
  end
end
