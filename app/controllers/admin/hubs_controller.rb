# frozen_string_literal: true

class Admin::HubsController < Admin::AdminBaseController
  include ExcelTools
  include ItineraryTools
  include Response
  include PricingTools
  include AwsConfig

  before_action :for_create, only: :create

  def index
    permitted_params

    query = {
      tenant_id: current_user.tenant_id
    }
    if params[:hub_type]
      query[:hub_type] = params[:hub_type]
    end

    if params[:hub_status]
      query[:hub_status] = params[:hub_status]
    end
    if params[:country]
      country = Country.where(name: params[:country])
      query[:country_id] = country.ids
    end
    hubs = Hub.where(query)
    all_hubs = hubs.map do |hub|
      { data: hub, location: hub.location.to_custom_hash }
    end
    paginated_hub_hashes = hubs.paginate(page: params[:page]).map do |hub|
      { data: hub, location: hub.location.to_custom_hash }
    end
    response_handler(hubs: paginated_hub_hashes, all_hubs: all_hubs, num_pages: hubs.count / 12)
  end

  def permitted_params
    params.permit(:hub_type, :hub_status)
  end

  def create
    response_handler(data: create_hub, location: @new_loc)
  end

  def update_mandatory_charges
    response_handler(
      hub:             create_hub_mandatory_charge.as_options_json,
      mandatoryCharge: hub.mandatory_charge
    )
  end

  def show
    hub = Hub.find(params[:id])
    resp = {
      hub:              hub.as_options_json,
      routes:           hub_route_map(hub),
      relatedHubs:      hub.nexus.hubs,
      schedules:        hub.layovers.limit(20),
      charges:          hub.local_charges,
      customs:          hub.customs_fees,
      location:         hub.location,
      mandatoryCharges: hub.mandatory_charge
    }
    response_handler(resp)
  end

  def download_hubs
    url = DocumentService::HubsWriter.new(tenant_id: current_user.tenant_id).perform
    response_handler(url: url, key: "hubs")
  end

  def set_status
    hub = Hub.find(params[:hub_id])
    hub.toggle_hub_status!
    response_handler(data: hub.as_options_json, location: hub.location.to_custom_hash)
  end

  def delete
    hub = Hub.find(params[:hub_id])
    hub.destroy!
    response_handler(id: params[:hub_id])
  end

  def update_image
    hub = Hub.find(params[:hub_id])
    hub.photo = save_on_aws(hub.tenant_id)
    hub.save!
    response_handler(hub.as_options_json)
  end

  def update
    hub = Hub.find(params[:id])
    location = hub.location
    new_loc = params[:location].as_json
    new_hub = params[:data].as_json
    country_name = new_loc.delete("country")
    country = Country.find_by_name(country_name)
    new_loc[:country_id] = country.id
    hub.update_attributes(new_hub)
    location.update_attributes(new_loc)
    response_handler(hub: hub.as_options_json, location: location)
  end

  def overwrite
    if params[:file]
      req = { "xlsx" => params[:file] }
      resp = ExcelTool::HubsOverwriter.new(params: req, _user: current_user).perform
      response_handler(resp)
    else
      response_handler(false)
    end
  end

  private

  def for_create
    @new_loc = geo_location
    @new_nexus = nexus
  end

  def hub_hash
    hub = params[:hub].as_json
    hub[:tenant_id] = current_user.tenant_id
    hub[:location_id] = @new_loc.id
    hub[:nexus_id] = @new_nexus.id
    hub
  end

  def create_hub
    Hub.create!(hub_hash)
  end

  def geo_location
    Location.create_and_geocode(params[:location].as_json)
  end

  def nexus
    Location.from_short_name("#{params[:location][:city]} ,#{params[:location][:country]}", "nexus")
  end

  def new_mandatory_charge
    nmc = params[:mandatoryCharge].as_json
    MandatoryCharge.find_by(nmc.except("id", "created_at", "updated_at"))
  end

  def create_hub_mandatory_charge
    hub = Hub.find(params[:id])
    hub.mandatory_charge = new_mandatory_charge
    hub.save!
    hub
  end

  def save_on_aws(tenant_id)
    file = params[:file]
    obj_key = "images/" + tenant_id.to_s + "/" + file.original_filename
    save_asset(file, obj_key)
    asset_url + obj_key
  end

  def hub_route_map(hub)
    hub.stops.map(&:itinerary).map do |itinerary|
      itinerary.as_options_json(methods: :routes)
    end
  end
end
