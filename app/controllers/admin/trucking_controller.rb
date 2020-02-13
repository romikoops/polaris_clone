# frozen_string_literal: true

class Admin::TruckingController < Admin::AdminBaseController
  include ExcelTools

  def index
    response_handler({})
  end

  def show
    hub = Hub.find_by(id: params[:id], sandbox: @sandbox)
    filters = {
      cargo_class: params[:cargo_class],
      truck_type: params[:truck_type],
      destination: params[:destination],
      carriage: params[:direction]
    }
    results = Trucking::Trucking.find_by_hub_id(
      hub_id: params[:id],
      options: {
        paginate: true,
        page: params[:page] || 1,
        filters: filters,
        per_page: params[:page_size],
        group_id: params[:group] == 'all' ? nil : params[:group],
        sandbox: @sandbox
      }
    )
    groups = Tenants::Group.where(
      tenant_id: Tenants::Tenant.find_by(legacy_id: current_tenant&.id)&.id,
      sandbox: @sandbox
    )
    response_handler(
      hub: hub,
      truckingPricings: results.map(&:as_index_result),
      page: params[:page],
      pages: results.total_pages,
      groups: groups
    )
  end

  def edit
    tp = Trucking::Trucking.find_by(id: params[:id], sandbox: @sandbox)
    ntp = params[:pricing].as_json
    tp.update_attributes(ntp.except('id', 'cargo_class', 'load_type', 'courier_id', 'truck_type', 'carriage'))
    response_handler(tp)
  end

  def create
    do_for_create
    response_handler(truckingHubId: truckingHubId)
  end

  def overwrite_zonal_trucking_by_hub
    if upload_params[:file]
      document = Legacy::File.create!(
        text: '',
        doc_type: 'truckings',
        sandbox: @sandbox,
        tenant: current_tenant,
        file: upload_params[:file]
      )

      args = {
        params: { 'xlsx' => upload_params[:file] },
        hub_id: upload_params[:id],
        user: current_user,
        group: upload_params[:group] == 'all' ? nil : upload_params[:group],
        sandbox: @sandbox,
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
    options[:tenant_id] = current_user.tenant_id
    options[:group_id] = options[:target] == 'all' ? nil : options[:target]
    url = DocumentService::TruckingWriter.new(options).perform
    response_handler(url: url, key: 'trucking')
  end

  def upload_params
    params.permit(:file, :group, :id)
  end
end
