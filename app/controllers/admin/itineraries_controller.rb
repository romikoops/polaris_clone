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
      response_handler(itinerary.as_json)
    else
      response_handler(app_error(itinerary.errors.full_messages.join("\n")))
    end
  end

  def destroy
    itinerary = Itinerary.find(params[:id]).destroy
    response_handler(true)
  end

  def stops
    response_handler(itinerary_stops.map(&:as_options_json))
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
    address_data = itinerary_row[2..-1]
    current_hub_type = nil
    address_data.each_with_index do |el, i|
      if i.even?
        current_hub_type = el
      else
        address = hub_address(current_hub_type, el)
        rl = find_or_create_itinerary_address(itinerary, address, i)
        itinerary.update_attributes(starthub: rl.address) if i == 1
        itinerary.update_attributes(endhub: rl.address) if i == address_data.length - 1
      end
    end
  end

  def find_or_create_itinerary_address(itinerary, address, index)
    ItineraryLocation.find_or_create_by(itinerary: itinerary,
                                        address: address,
                                        position_in_hub_chain: (index + 1) / 2)
  end

  def hub_address(current_hub_type, el)
    Address.find_by(address_type: "hub_#{current_hub_type.downcase}", hub_name: el)
  end

  def first_sheet
    xlsx = open_file(params['xlsx'])
    xlsx.sheet(xlsx.sheets.first)
  end

  def itinerary_params
    {
      mode_of_transport: params['itinerary']['mot'],
      name: params['itinerary']['name'],
      tenant_id: current_user.tenant_id
    }
  end

  def as_json_itineraries
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    itineraries.map(&:as_options_json)
  end

  def params_stops
    params['itinerary']['stops'].map.with_index { |h, i| Stop.new(hub_id: h, index: i) }
  end

  def app_error(message)
    ApplicationError.new(
      http_code: 400,
      code: SecureRandom.uuid,
      message: message
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
    itinerary.notes.find_or_create_by!(body: params[:notes][:body],
                                       header: params[:notes][:header],
                                       level: params[:notes][:level])
    itinerary.notes
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
