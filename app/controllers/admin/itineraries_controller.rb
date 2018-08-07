# frozen_string_literal: true

class Admin::ItinerariesController < Admin::AdminBaseController
  include PricingTools
  include ItineraryTools

  def index
    map_data = current_user.tenant.map_data
    response_handler(mapData: map_data, itineraries: as_json_itineraries)
  end

  def create
    itinerary = formated_itinerary
    if itinerary.save
      response_handler(itinerary)
    else
      response_handler(app_error(itinerary.errors.full_messages.join("\n")))
    end
  end

  def destroy
    itinerary = Itinerary.find(params[:id]).destroy
    response_handler(true)
  end

  def stops
    response_handler(itinerary_stops)
  end

  def edit_notes
    response_handler(itinerary_with_notes)
  end

  def show
    itinerary = Itinerary.find(params[:id])
    resp = { hubs: itinerary.hubs,
      itinerary: itinerary,
      hubItinerarys: itinerary.as_options_json,
      schedules: itinerary.prep_schedules(10),
      stops: itinerary.stops.order(:index),
      notes: itinerary.notes }
    response_handler(resp)
  end

  private

  def work_itinerary(itinerary_row)
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
        location = hub_location(current_hub_type, el)
        rl = find_or_create_itinerary_location(itinerary, location, i)
        itinerary.update_attributes(starthub: rl.location) if i == 1
        itinerary.update_attributes(endhub: rl.location) if i == location_data.length - 1
      end
    end
  end

  def find_or_create_itinerary_location(itinerary, location, index)
    ItineraryLocation.find_or_create_by(itinerary: itinerary,
      location: location,
      position_in_hub_chain: (index + 1) / 2)
  end

  def hub_location(current_hub_type, el)
    Location.find_by(location_type: "hub_#{current_hub_type.downcase}", hub_name: el)
  end

  def first_sheet
    xlsx = open_file(params["xlsx"])
    xlsx.sheet(xlsx.sheets.first)
  end

  def itinerary_params
    {
      mode_of_transport: params['itinerary']["mot"],
      name:              params['itinerary']["name"],
      tenant_id:         current_user.tenant_id
    }
  end

  def as_json_itineraries
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    itineraries.map { |itinerary| itinerary.as_options_json() }
  end

  def params_stops
    params["itinerary"]["stops"].map.with_index { |h, i| Stop.new(hub_id: h, index: i) }
  end

  def app_error(message)
    ApplicationError.new(
      http_code: 400,
      code:      SecureRandom.uuid,
      message:   message
    )
  end

  def formated_itinerary
    itinerary = Itinerary.find_or_initialize_by(itinerary_params)
    itinerary.stops = params_stops
    itinerary
  end

  def itinerary_stops
    itinerary = Itinerary.find(params[:id])
    itinerary.stops.order(:index)
  end

  def itinerary_with_notes
    itinerary = Itinerary.find(params[:id])
    itinerary.notes.create!(body: params[:notes][:body],
      header: params[:notes][:header],
      level: params[:notes][:level])
  end

  def new_ids
    @new_ids ||= []
  end

  def old_ids
    Itinerary.pluck(:id)
  end

  def kicked_itinerary_ids
    old_ids - new_ids
  end

  def destroy_itins
   Itinerary.where(id: kicked_itinerary_ids).destroy_all
  end
end
