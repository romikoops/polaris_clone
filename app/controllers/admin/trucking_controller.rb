# frozen_string_literal: true

class Admin::TruckingController < Admin::AdminBaseController
  include ExcelTools

  def index
    response_handler({})
  end

  def show
    hub = Hub.find_by(id: params[:id])
    filters = {
      cargo_class: params[:cargo_class],
      truck_type: params[:truck_type],
      destination: params[:destination],
      carriage: params[:direction],
      courier_name: params[:courier]
    }
    results = Trucking::Trucking.find_by_hub_id(
      hub_id: params[:id],
      options: {
        paginate: true,
        page: params[:page] || 1,
        filters: filters,
        per_page: params[:page_size],
        group_id: params[:group] == "all" ? default_group.id : params[:group]
      }
    )

    groups = Groups::Group.where(organization_id: current_organization)
    trucking_providers = Legacy::TenantVehicle
      .where(id: Trucking::Trucking
                  .where(hub_id: params[:id], organization: current_organization)
                  .select(:tenant_vehicle_id).distinct)
      .pluck(:name)

    response_handler(
      hub: hub,
      truckingPricings: results.map(&:as_index_result),
      page: params[:page],
      pages: results.total_pages,
      groups: groups,
      providers: trucking_providers.select(&:presence)
    )
  end

  def create
    do_for_create
    response_handler(truckingHubId: truckingHubId)
  end

  def upload
    hub = Legacy::Hub.find(params[:id])
    handle_upload(
      params: upload_params,
      text: "group_id:#{params[:group_id] || "all"},hub_id: #{hub.id}",
      type: "trucking",
      options: {
        group_id: upload_params[:group_id],
        applicable: hub,
        user: current_user
      }
    )
  end

  def overwrite_zonal_trucking_by_hub
    if upload_params[:file]
      document = Legacy::File.create!(
        text: "",
        doc_type: "truckings",
        organization: current_organization,
        file: upload_params[:file]
      )

      args = {
        params: {"xlsx" => upload_params[:file]},
        hub_id: upload_params[:id],
        user: organization_user,
        group: upload_params[:group] == "all" ? nil : upload_params[:group],
        document: document
      }

      resp = Trucking::Excel::Inserter.new(args).perform

      response_handler(resp)
    else
      response_handler(false)
    end
  end

  def download
    options = params[:options].as_json.symbolize_keys
    options[:organization_id] = current_organization.id
    options[:group_id] = options[:target] == "all" ? nil : options[:target]
    url = DocumentService::TruckingWriter.new(options).perform
    response_handler(url: url, key: "trucking")
  end

  def upload_params
    params.permit(:async, :file, :group, :id)
  end
end
