# frozen_string_literal: true

class Admin::HubsController < Admin::AdminBaseController # rubocop:disable Metrics/ClassLength
  include ExcelTools
  include ItineraryTools
  include Response
  include AwsConfig

  before_action :for_create, only: :create
  before_action :permitted_params, only: :index

  def index
    paginated_hubs = handle_search.paginate(pagination_options)
    response_hubs = paginated_hubs.map do |hub|
      for_table(hub)
    end

    response_handler(
      pagination_options.merge(
        hubsData: response_hubs,
        numPages: paginated_hubs.total_pages
      )
    )
  end

  def permitted_params
    params.permit(:hub_type, :hub_status)
  end

  def create
    response_handler(data: create_hub, address: @new_loc)
  end

  def update_mandatory_charges
    hub = create_hub_mandatory_charge
    response_handler(
      hub: hub.as_options_json,
      mandatoryCharge: hub.mandatory_charge
    )
  end

  def show
    hub = Hub.find_by(id: params[:id], sandbox: @sandbox)
    resp = {
      hub: hub.as_options_json,
      routes: hub_route_map(hub),
      relatedHubs: hub.nexus.hubs.where(sandbox: @sandbox),
      schedules: hub.layovers.limit(20),
      address: hub.address,
      mandatoryCharge: hub.mandatory_charge
    }
    response_handler(resp)
  end

  def download_hubs
    url = DocumentService::HubsWriter.new(tenant_id: current_user.tenant_id, sandbox: @sandbox).perform
    response_handler(url: url, key: 'hubs')
  end

  def options_search
    list_options = current_tenant.hubs
                                 .where(sandbox: @sandbox)
                                 .list_search(params[:query])
                                 .limit(30).map do |it|
      { label: it.name, value: it.as_options_json }
    end
    response_handler(list_options)
  end

  def set_status
    hub = Hub.find_by(id: params[:hub_id], sandbox: @sandbox)
    hub.toggle_hub_status!
    response_handler(data: hub.as_options_json, address: hub.address.to_custom_hash)
  end

  def delete
    hub = Hub.find_by(id: params[:hub_id], sandbox: @sandbox)
    hub.destroy!
    response_handler(id: params[:hub_id])
  end

  def update_image
    hub = Hub.find_by(id: params[:hub_id], sandbox: @sandbox)
    hub.photo = save_on_aws(hub.tenant_id)
    hub.save!
    response_handler(hub.as_options_json)
  end

  def update
    hub = Hub.find_by(id: params[:id], sandbox: @sandbox)
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
      resp = ExcelTool::HubsOverwriter.new(params: req, _user: current_user, sandbox: @sandbox).perform
      response_handler(resp)
    else
      response_handler(false)
    end
  end

  def all_hubs
    processed_hubs = current_user.tenant.hubs.where(sandbox: @sandbox).map do |hub|
      { data: hub, address: hub.address.to_custom_hash }
    end
    response_handler(hubs: processed_hubs)
  end

  private

  def handle_search
    hubs_relation = ::Legacy::Hub.where(tenant_id: current_tenant.id, sandbox: @sandbox)

    {
      country: ->(query, param) { query.country_search(param) },
      name: ->(query, param) { query.name_search(param) },
      name_desc: ->(query, param) { query.ordered_by(:name, param) },
      locode: ->(query, param) { query.locode_search(param) },
      locode_desc: ->(query, param) { query.ordered_by(:hub_code, param) },
      type: ->(query, param) { param == 'all' ? query : query.where(hub_type: param) },
      type_desc: ->(query, param) { query.ordered_by(:hub_type, param) },
      country_desc: lambda do |query, param|
                      query.left_joins(:country)
                           .order("countries.name #{param.to_s == 'true' ? 'DESC' : 'ASC'}")
                    end
    }.each do |key, lambd|
      hubs_relation = lambd.call(hubs_relation, search_params[key]) if search_params[key]
    end

    hubs_relation
  end

  def for_table(hub)
    hub.as_json(
      include: {
        nexus: { only: %i(id name) },
        address: {
          include: {
            country: { only: %i(name) }
          }
        }
      },
      methods: %i(earliest_expiration)
    )
  end

  def pagination_options
    {
      page: current_page,
      per_page: (params[:page_size] || params[:per_page])&.to_i
    }.compact
  end

  def current_page
    params[:page]&.to_i || 1
  end

  def search_params
    params.permit(
      :type,
      :type_desc,
      :name_desc,
      :country_desc,
      :country,
      :locode_desc,
      :locode,
      :name,
      :page_size,
      :per_page
    )
  end

  def for_create
    @new_loc = geo_address
    @new_nexus = nexus
  end

  def hub_hash
    hub = params[:hub].as_json
    hub[:tenant_id] = current_user.tenant_id
    hub[:address_id] = @new_loc.id
    hub[:nexus_id] = @new_nexus.id
    hub[:sandbox] = @sandbox
    hub
  end

  def create_hub
    hub_hash[:mandatory_charge_id] = MandatoryCharge.falsified unless hub_hash[:mandatory_charge_id]
    Hub.create!(hub_hash)
  end

  def geo_address
    Address.create_and_geocode(params[:address].as_json.merge(sandbox: @sandbox))
  end

  def nexus
    Nexus.from_short_name("#{params[:address][:city]} ,#{params[:address][:country]}", current_user.tenant_id)
  end

  def new_mandatory_charge
    nmc = params[:mandatoryCharge].as_json
    MandatoryCharge.find_by(nmc.except('id', 'created_at', 'updated_at'))
  end

  def create_hub_mandatory_charge
    hub = Hub.find_by(id: params[:id], sandbox: @sandbox)
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
    hub.stops.where(sandbox: @sandbox).map(&:itinerary).map do |itinerary|
      itinerary.as_options_json(methods: :routes)
    end
  end
end
