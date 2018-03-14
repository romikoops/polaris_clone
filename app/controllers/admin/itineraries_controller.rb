class Admin::ItinerariesController < ApplicationController
  before_action :require_login_and_role_is_admin
  include PricingTools
  include ItineraryTools

  

  def index
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    response_handler(itineraries)
  end
  def create
    new_itinerary_data = params[:itinerary].as_json
    itinerary = Itinerary.find_or_create_by(mode_of_transport: new_itinerary_data["mot"], name: new_itinerary_data["name"], tenant_id: current_user.tenant_id)
    new_itinerary_data["stops"].each_with_index { |h, i|  itinerary.stops.create(hub_id: h, index: i)}
    itinerary.set_scope!
    current_user.tenant.update_route_details
    response_handler(itinerary)
  end

  def stops
    itinerary = Itinerary.find(params[:id])
    stops = itinerary.stops.order(:index)
    response_handler(stops)
  end

  def show
    itinerary = Itinerary.find(params[:id])
    pricings = get_itinerary_pricings_array(params[:id], current_user.tenant_id)
    hubs = itinerary.hubs
    detailed_itineraries = get_itinerary_options(itinerary)

    schedules = itinerary.prep_schedules(20)
     
    resp = {hubs: hubs, itinerary: itinerary, hubItinerarys: detailed_itineraries, schedules: schedules}
    response_handler(resp)
  end

  def overwrite
    old_ids = Itinerary.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
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
        if i % 2 == 0
          current_hub_type = el
        else
          location = Location.find_by(location_type: "hub_#{current_hub_type.downcase}", hub_name: el)
          rl = ItineraryLocation.find_or_create_by(itinerary: itinerary, location: location, position_in_hub_chain: (i+1)/2)
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
end
