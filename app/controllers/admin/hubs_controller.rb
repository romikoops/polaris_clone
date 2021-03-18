# frozen_string_literal: true

class Admin::HubsController < Admin::AdminBaseController
  include ExcelTools
  include Response
  include AwsConfig

  before_action :for_create, only: :create
  before_action :permitted_params, only: :index

  def index
    paginated_hubs = handle_search.paginate(pagination_options)
    response_hubs = decorate_table_list(hubs: paginated_hubs).map(&:legacy_index_json)

    response_handler(
      pagination_options.merge(
        hubsData: response_hubs,
        numPages: paginated_hubs.total_pages.zero? ? 1 : paginated_hubs.total_pages
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
      hub: decorated_hub(hub: hub).legacy_json,
      mandatoryCharge: hub.mandatory_charge
    )
  end

  def show
    hub = Hub.find_by(id: params[:id])
    resp = {
      hub: decorated_hub(hub: hub).legacy_json,
      routes: hub_route_map(hub),
      relatedHubs: hub.nexus.hubs,
      schedules: hub.layovers.limit(20),
      address: hub.address,
      mandatoryCharge: hub.mandatory_charge
    }
    response_handler(resp)
  end

  def options_search
    list_hubs = Hub.where(organization: current_organization)
      .name_search(params[:query])
      .limit(30)
    list_options = decorate_table_list(hubs: list_hubs).map(&:select_option)
    response_handler(list_options)
  end

  def set_status
    hub = Hub.find_by(id: params[:hub_id])
    hub.toggle_hub_status!
    response_handler(
      data: decorated_hub(hub: hub).legacy_json, address: hub.address.to_custom_hash
    )
  end

  def delete
    hub = Hub.find_by(id: params[:hub_id])
    hub.destroy!
    response_handler(id: params[:hub_id])
  end

  def update_image
    hub = Hub.find_by(id: params[:hub_id])
    hub.photo = save_on_aws(hub.organization_id)
    hub.save!
    response_handler(decorated_hub(hub: hub).legacy_json)
  end

  def update
    hub = Hub.find_by(id: params[:id])
    address = hub.address
    new_loc = params[:address].as_json
    new_hub = params[:data].as_json
    country_name = new_loc.delete("country")
    country = Country.find_by(name: country_name)
    new_loc[:country_id] = country.id
    hub.update(new_hub)
    address.update(new_loc)
    response_handler(hub: decorated_hub(hub: hub).legacy_json, address: address)
  end

  def all_hubs
    processed_hubs = Hub.where(organization_id: current_organization.id).map { |hub|
      {data: hub, address: hub.address.to_custom_hash}
    }
    response_handler(hubs: processed_hubs)
  end

  def upload
    handle_upload(
      params: upload_params,
      text: "#{current_organization.slug} hubs upload #{Time.zone.today.strftime("%d/%m/%Y")}",
      type: "hubs",
      options: {
        group_id: upload_params[:group_id]
      }
    )
  end

  def download
    category_identifier = "hubs"
    file_name = "#{current_organization.slug}__#{category_identifier}_#{Time.zone.today.strftime("%d/%m/%Y")}"

    document = ExcelDataServices::Loaders::Downloader.new(
      organization: current_organization,
      category_identifier: category_identifier,
      file_name: file_name
    ).perform

    response_handler(
      key: category_identifier,
      url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: "attachment")
    )
  end

  private

  def handle_search
    hubs_relation = ::Legacy::Hub.where(organization_id: current_organization.id)
    country_table_ref =
      if search_params[:country].present? && search_params[:country_desc].present?
        "countries_hubs"
      else
        "countries"
      end
    {
      country: ->(query, param) { query.country_search(param) },
      name: ->(query, param) { query.name_search(param) },
      name_desc: ->(query, param) { query.ordered_by(:name, param) },
      locode: ->(query, param) { query.locode_search(param) },
      locode_desc: ->(query, param) { query.ordered_by(:hub_code, param) },
      type: ->(query, param) { param == "all" ? query : query.where(hub_type: param) },
      type_desc: ->(query, param) { query.ordered_by(:hub_type, param) },
      country_desc: lambda do |query, param|
                      query.left_joins(:country).order(
                        "#{country_table_ref}.name #{param.to_s == "true" ? "DESC" : "ASC"}"
                      )
                    end
    }.each do |key, lambd|
      hubs_relation = lambd.call(hubs_relation, search_params[key]) if search_params[key]
    end

    hubs_relation
  end

  def for_table(hub)
    hub.as_json(
      include: {
        nexus: {only: %i[id name]},
        address: {
          include: {
            country: {only: %i[name]}
          }
        }
      },
      methods: %i[earliest_expiration]
    )
  end

  def decorate_table_list(hubs:)
    Legacy::HubDecorator.decorate_collection(hubs, context: {scope: current_scope})
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
    hub[:organization_id] = current_organization.id
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
    Nexus.from_short_name("#{params[:address][:city]} ,#{params[:address][:country]}", current_organization.id)
  end

  def new_mandatory_charge
    nmc = params[:mandatoryCharge].as_json
    MandatoryCharge.find_by(nmc.except("id", "created_at", "updated_at"))
  end

  def create_hub_mandatory_charge
    hub = Hub.find_by(id: params[:id])
    hub.mandatory_charge = new_mandatory_charge
    hub.save!
    hub
  end

  def save_on_aws(organization_id)
    file = params[:file]
    obj_key = "images/" + organization_id.to_s + "/" + file.original_filename
    save_asset(file, obj_key)
    asset_url + obj_key
  end

  def hub_route_map(hub)
    hub.stops.map(&:itinerary).map do |itinerary|
      itinerary.as_options_json(methods: :routes)
    end
  end

  def upload_params
    params.permit(:async, :file, :mot, :load_type, :group_id)
  end

  def decorated_hub(hub:)
    Legacy::HubDecorator.new(hub, context: {scope: current_scope})
  end
end
