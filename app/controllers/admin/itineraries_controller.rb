# frozen_string_literal: true

class Admin::ItinerariesController < ApplicationController
  before_action :require_login_and_role_is_admin
  include PricingTools
  include ItineraryTools

  def index
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    as_json_itineraries = itineraries.map { |itinerary| itinerary.as_options_json(methods: :routes) }
    response_handler(as_json_itineraries)
  end

  def create
    itinerary = Itinerary.find_or_initialize_by(itinerary_params)
    stops     = params["itinerary"]["stops"].map.with_index { |h, i| Stop.new(hub_id: h, index: i) }

    itinerary.stops = stops
    if itinerary.save
      response_handler(itinerary)
    else
      error = ApplicationError.new(
        http_code: 400,
        code:      SecureRandom.uuid,
        message:   itineraries.errors.full_messages.join("\n")
      )
      response_handler(error)
    end
  end

  def destroy
    itinerary = Itinerary.find(params[:id]).destroy
    response_handler(true)
  end

  def stops
    itinerary = Itinerary.find(params[:id])
    stops = itinerary.stops.order(:index)
    response_handler(stops)
  end

  def edit_notes
    itinerary = Itinerary.find(params[:id])
    itinerary.notes.create!(body: params[:notes][:body], header: params[:notes][:header], level: params[:notes][:level])
    response_handler(itinerary)
  end

  def show
    itinerary = Itinerary.find(params[:id])
    hubs = itinerary.hubs
    detailed_itineraries = itinerary.as_options_json
    stops = itinerary.stops.order(:index)
    schedules = itinerary.prep_schedules(10)
    notes = itinerary.notes
    resp = { hubs: hubs, itinerary: itinerary, hubItinerarys: detailed_itineraries, schedules: schedules, stops: stops, notes: notes }
    response_handler(resp)
  end
  
  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end

  private

  def itinerary_params
    {
      mode_of_transport: params["mot"],
      name:              params["name"],
      tenant_id:         current_user.tenant_id
    }
  end
end
