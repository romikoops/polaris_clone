# frozen_string_literal: true

class Admin::TruckingController < Admin::AdminBaseController
  include ExcelTools

  def index
    response_handler({})
  end

  def show
    response_handler(
      hub: hub,
      truckingPricings: as_index_result(truckings: paginated_truckings),
      page: show_params[:page],
      pages: paginated_truckings.total_pages,
      groups: groups,
      providers: trucking_providers.select(&:presence)
    )
  end

  def create
    do_for_create
    response_handler(truckingHubId: truckingHubId)
  end

  def upload
    hub = Legacy::Hub.find(upload_hub_id)
    handle_upload(
      params: upload_params,
      text: "group_id:#{upload_group_id || "all"},hub_id: #{hub.id}",
      type: "trucking",
      options: {
        group_id: upload_group_id,
        hub_id: hub.id
      }
    )
  end

  def download
    options = params[:options].as_json.symbolize_keys
    group = Groups::Group.find_by(id: options[:target])
    hub = Legacy::Hub.find_by(id: options[:hub_id])
    sheet_string = ["trucking", group.name, hub.name, options[:load_type]].join("_")
    file_name = "#{current_organization.slug}__#{sheet_string}"
    handle_download(category_identifier: "trucking", file_name: file_name, options: options.merge(
      organization_id: current_organization.id,
      group_id: group.id
    ))
  end

  private

  def show_params
    params.permit(:id,
      :cargo_class,
      :truck_type,
      :destination,
      :direction,
      :courier,
      :group,
      :page,
      :per_page,
      :paginate)
  end

  def upload_params
    params.permit(:async, :file)
  end

  def upload_group_id
    params.require(:group_id)
  end

  def upload_hub_id
    params.require(:id)
  end

  def groups
    @groups ||= Groups::Group.where(organization_id: current_organization)
  end

  def trucking_providers
    Legacy::TenantVehicle
      .where(organization: current_organization, mode_of_transport: "truck_carriage")
      .joins(:carrier)
      .pluck("carriers.name")
  end

  def hub
    Legacy::Hub.find_by(id: params[:id])
  end

  def filters
    {
      cargo_class: show_params[:cargo_class],
      truck_type: show_params[:truck_type],
      destination: show_params[:destination],
      carriage: show_params[:direction],
      courier_name: show_params[:courier]
    }
  end

  def truckings_by_hub
    ::Trucking::Queries::FindByHubIds.new({
      hub_ids: [show_params[:id]],
      filters: filters,
      group_id: show_params[:group].present? ? show_params[:group] : default_group.id
    }).perform
  end

  def paginated_truckings
    @paginated_truckings ||= truckings_by_hub.paginate(page: show_params[:page] || 1, per_page: show_params[:per_page] || 20)
  end

  def as_index_result(truckings:)
    truckings.includes(:location, :tenant_vehicle).map do |trucking|
      {
        "truckingPricing" => trucking.as_json,
        "countryCode" => trucking.location.country.code,
        "courier" => trucking.tenant_vehicle.name
      }.merge(location_info(trucking: trucking))
    end
  end

  def location_info(trucking:)
    trucking_location = trucking.location
    return {} if trucking_location.nil?

    key =
      case trucking_location.query
      when "postal_code"
        "zipCode"
      when "distance"
        "distance"
      else
        "city"
      end

    { key => trucking_location.data }
  end
end
