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
    stops     = params["stops"].map.with_index { |h, i| Stop.new(hub_id: h, index: i) }

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

  def overwrite
    old_ids = Itinerary.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params["xlsx"])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    itinerary_rows = first_sheet.parse

    itinerary_rows.each do |itinerary_row|
      itinerary_row = itinerary_row.compact # remove nil's
      itinerary = Itinerary.find_or_create_by(name: itinerary_row[0])
      new_ids << itinerary.id

      itinerary.trade_direction = itinerary_row[1].downcase

      location_data = itinerary_row[2..-1]
      current_hub_type = nil
      location_data.each_with_index do |el, i|
        if i.even?
          current_hub_type = el
        else
          location = Location.find_by(location_type: "hub_#{current_hub_type.downcase}", hub_name: el)
          rl = ItineraryLocation.find_or_create_by(itinerary: itinerary, location: location, position_in_hub_chain: (i + 1) / 2)
          itinerary.update_attributes(starthub: rl.location) if i == 1
          itinerary.update_attributes(endhub: rl.location) if i == location_data.length - 1
        end
      end
    end

    kicked_itinerary_ids = old_ids - new_ids
    Itinerary.where(id: kicked_itinerary_ids).destroy_all

    redirect_to :back
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
