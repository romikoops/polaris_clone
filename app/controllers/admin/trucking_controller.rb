# frozen_string_literal: true

class Admin::TruckingController < Admin::AdminBaseController
  include ExcelTools
  include TruckingTools

  def index
    response_handler({})
  end

  def show
    hub = Hub.find(params[:id])
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
        per_page: params[:page_size]
      }
    )
    response_handler(
      hub: hub,
      truckingPricings: results.map(&:as_index_result),
      page: params[:page],
      pages: results.total_pages
    )
  end

  def edit
    tp = Trucking::Trucking.find(params[:id])
    ntp = params[:pricing].as_json
    tp.update_attributes(ntp.except('id', 'cargo_class', 'load_type', 'courier_id', 'truck_type', 'carriage'))
    response_handler(tp)
  end

  def create
    do_for_create
    response_handler(truckingHubId: truckingHubId)
  end

  def overwrite_zonal_trucking_by_hub
    if params[:file]
      args = {
        params: { 'xlsx' => params[:file] },
        hub_id: params[:id],
        user: current_user
      }
      ## New Code
      # resp = Trucking::Excel::Inserter.new(args).perform

      ## Legacy Inserter Code
      resp = Trucking::Excel::LegacyInserter.new(args).perform
      response_handler(resp)
    else
      response_handler(false)
    end
  end

  def download
    options = params[:options].as_json.symbolize_keys
    options[:tenant_id] = current_user.tenant_id
    url = DocumentService::TruckingWriter.new(options).perform
    response_handler(url: url, key: 'trucking')
  end
end
