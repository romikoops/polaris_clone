# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  include ItineraryTools
  before_action :require_login_and_role_is_admin
  def index

    options = {methods: [:selected_offer, :mode_of_transport], include:[ { destination_nexus: {}},{ origin_nexus: {}}, { destination_hub: {}}, { origin_hub: {}} ]}
    requested_shipments = Shipment.where(
      status:    %w[requested requested_by_unconfirmed_account],
      tenant_id: current_user.tenant_id
    ).order(booking_placed_at: :desc)
    open_shipments = Shipment.where(
      status:    %w[in_progress confirmed],
      tenant_id: current_user.tenant_id
    ).order(booking_placed_at: :desc)
    finished_shipments = Shipment.where(status: "finished", tenant_id: current_user.tenant_id).order(booking_placed_at: :desc)
    @requested_shipments = requested_shipments.map{|shipment| shipment.as_json(options)}
    @open_shipments = open_shipments.map{|shipment| shipment.as_json(options)}
    @finished_shipments = finished_shipments.map{|shipment| shipment.as_json(options)}
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    @detailed_itineraries = Itinerary.where(tenant_id: current_user.tenant_id).map(&:as_options_json)
    @hubs = Hub.prepped(current_user)
    tenant = Tenant.find(current_user.tenant_id)
    @train_schedules = tenant.itineraries.where(mode_of_transport: "rail").limit(10).flat_map { |it| it.prep_schedules(5) }
    @ocean_schedules = tenant.itineraries.where(mode_of_transport: "ocean").limit(10).flat_map { |it| it.prep_schedules(5) }
    @air_schedules = tenant.itineraries.where(mode_of_transport: "air").limit(10).flat_map { |it| it.prep_schedules(5) }
    # schedules = @train_schedules + @air_schedules + @ocean_schedules
    # byebug
    # schedules.sort! {|x,y| x}
    response_handler(air: @air_schedules, train: @train_schedules, ocean: @ocean_schedules, itineraries: @detailed_itineraries, hubs: @hubs, shipments: { requested: @requested_shipments, open: @open_shipments, finished: @finished_shipments })
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
