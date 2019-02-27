# frozen_string_literal: true

class Admin::HubsController < Admin::AdminBaseController
  include ExcelTools
  include ItineraryTools
  include Response
  include PricingTools
  include AwsConfig

  before_action :for_create, only: :create
  before_action :permitted_params, only: :index

  def index
    query = {
      tenant_id: current_user.tenant_id
    }
    query[:hub_type] = params[:hub_type].split(',') if params[:hub_type]

    query[:name] = params[:name] if params[:name]

    query[:hub_status] = params[:hub_status].split(',') if params[:hub_status]
    if params[:country_ids]
      hubs = Hub.where(query).joins(:address).where('addresses.country_id IN (?)', params[:country_ids].split(',').map(&:to_i))
    else
      hubs = Hub.where(query).order('name ASC')
    end

    paginated_hub_hashes = hubs.paginate(page: params[:page]).map do |hub|
      { data: hub, address: hub.address.to_custom_hash }
    end
    response_handler(hubs: paginated_hub_hashes, num_pages: (hubs.count / 9.0).ceil)
  end

  def permitted_params
    params.permit(:hub_type, :hub_status)
  end

  def create
    response_handler(data: create_hub, address: @new_loc)
  end

  def update_mandatory_charges
    response_handler(
      hub: create_hub_mandatory_charge.as_options_json,
      mandatoryCharge: hub.mandatory_charge
    )
  end

  def show
    hub = Hub.find(params[:id])
    charges = hub.local_charges
    service_levels = charges.map(&:tenant_vehicle).uniq.map(&:with_carrier).map do |tenant_vehicle|
      carrier_name = tenant_vehicle['carrier'] ?
      "#{tenant_vehicle['carrier']['name']} - #{tenant_vehicle['name']}" :
      tenant_vehicle['name']
      { label: carrier_name.capitalize.to_s, value: tenant_vehicle['id'] }
    end
    counter_part_hubs = charges.map(&:counterpart_hub).uniq.compact.map do |hub|
      { label: hub.name, value: hub }
    end
    resp = {
      hub: hub.as_options_json,
      routes: hub_route_map(hub),
      relatedHubs: hub.nexus.hubs,
      schedules: hub.layovers.limit(20),
      address: hub.address,
      mandatoryCharges: hub.mandatory_charge
    }
    response_handler(resp)
  end

  def download_hubs
    url = DocumentService::HubsWriter.new(tenant_id: current_user.tenant_id).perform
    response_handler(url: url, key: 'hubs')
  end

  def set_status
    hub = Hub.find(params[:hub_id])
    hub.toggle_hub_status!
    response_handler(data: hub.as_options_json, address: hub.address.to_custom_hash)
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
    address = hub.address
    new_loc = params[:address].as_json
    new_hub = params[:data].as_json
    country_name = new_loc.delete('country')
    country = Country.find_by_name(country_name)
    new_loc[:country_id] = country.id
    hub.update_attributes(new_hub)
    address.update_attributes(new_loc)
    response_handler(hub: hub.as_options_json, address: address)
  end

  def overwrite
    if params[:file]
      req = { 'xlsx' => params[:file] }
      resp = ExcelTool::HubsOverwriter.new(params: req, _user: current_user).perform
      response_handler(resp)
    else
      response_handler(false)
    end
  end

  def search
    query = {
      tenant_id: current_user.tenant_id
    }
    query[:hub_type] = params[:hub_type].split(',') if params[:hub_type]

    query[:name] = params[:name] if params[:name]

    query[:hub_status] = params[:hub_status].split(',') if params[:hub_status]
    if params[:country_ids]
      hubs = Hub.where(query).joins(:address).where('addresses.country_id IN (?)', params[:country_ids].split(',').map(&:to_i))
    else
      hubs = Hub.where(query).order('name ASC')
    end
    hub_results = hubs.where('name ILIKE ?', "%#{params[:text]}%")

    paginated_hub_hashes = hub_results.paginate(page: params[:page]).map do |hub|
      { data: hub, address: hub.address.to_custom_hash }
    end
    response_handler(hubs: paginated_hub_hashes, num_pages: hubs.count / 12)
  end

  def all_hubs
    processed_hubs = current_user.tenant.hubs.map do |hub|
      { data: hub, address: hub.address.to_custom_hash }
    end
    response_handler(hubs: processed_hubs)
  end

  private

  def for_create
    @new_loc = geo_address
    @new_nexus = nexus
  end

  def hub_hash
    hub = params[:hub].as_json
    hub[:tenant_id] = current_user.tenant_id
    hub[:address_id] = @new_loc.id
    hub[:nexus_id] = @new_nexus.id
    hub
  end

  def create_hub
    hub_hash[:mandatory_charge_id] = MandatoryCharge.falsified unless hub_hash[:mandatory_charge_id]
    Hub.create!(hub_hash)
  end

  def geo_address
    Address.create_and_geocode(params[:address].as_json)
  end

  def nexus
    Nexus.from_short_name("#{params[:address][:city]} ,#{params[:address][:country]}", current_user.tenant_id)
  end

  def new_mandatory_charge
    nmc = params[:mandatoryCharge].as_json
    MandatoryCharge.find_by(nmc.except('id', 'created_at', 'updated_at'))
  end

  def create_hub_mandatory_charge
    hub = Hub.find(params[:id])
    hub.mandatory_charge = new_mandatory_charge
    hub.save!
    hub
  end

  def save_on_aws(tenant_id)
    file = params[:file]
    obj_key = 'images/' + tenant_id.to_s + '/' + file.original_filename
    save_asset(file, obj_key)
    asset_url + obj_key
  end

  def hub_route_map(hub)
    hub.stops.map(&:itinerary).map do |itinerary|
      itinerary.as_options_json(methods: :routes)
    end
  end
end
