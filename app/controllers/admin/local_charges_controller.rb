# frozen_string_literal: true

class Admin::LocalChargesController < Admin::AdminBaseController
  include ExcelTools

  def hub_charges
    hub = Hub.find_by(id: params[:id])
    charges = hub.local_charges
    service_levels = charges.map(&:tenant_vehicle).uniq.map(&:with_carrier).map { |tenant_vehicle|
      carrier_name = if tenant_vehicle["carrier"]
        "#{tenant_vehicle["carrier"]["name"]} - #{tenant_vehicle["name"]}"
      else
        tenant_vehicle["name"]
      end
      {label: carrier_name.capitalize.to_s, value: tenant_vehicle["id"]}
    }

    counter_part_hubs = charges.map(&:counterpart_hub).uniq.compact.map { |hub|
      {label: hub.name, value: hub}
    }

    resp = {
      hub_id: params[:id],
      charges: hub.local_charges,
      customs: hub.customs_fees,
      serviceLevels: service_levels,
      counterpartHubs: counter_part_hubs
    }
    response_handler(resp)
  end

  def edit
    data = params[:data].as_json
    id = data.delete("id")
    local_charge = ::Legacy::LocalCharge.find_by(id: id)
    local_charge.update(fees: data["fees"])
    response_handler(local_charge)
  end

  def destroy
    result = ::Legacy::LocalCharge.find(params[:id]).destroy
    response_handler(success: result)
  end

  def index
    paginated_local_charges = handle_search.paginate(pagination_options)
    response_local_charges = paginated_local_charges.map { |local_charge|
      for_index_json(local_charge)
    }
    response_handler(
      pagination_options.merge(
        localChargeData: response_local_charges,
        numPages: paginated_local_charges.total_pages
      )
    )
  end

  def edit_customs
    data = params[:data].as_json
    id = data["id"]
    data.delete("id")
    customs_fee = CustomsFee.find(id)
    customs_fee.update(fees: data["fees"])
    response_handler(customs_fee)
  end

  def upload
    handle_upload(
      params: upload_params,
      text: "group_id:#{upload_params[:group_id] || "all"}",
      type: "local_charges",
      options: {
        group_id: upload_params[:group_id],
        user: organization_user
      }
    )
  end

  def download
    category_identifier = "local_charges"
    mot = download_params[:mot]
    file_name = "#{current_organization.slug}__#{category_identifier}_#{mot}"

    document = ExcelDataServices::Loaders::Downloader.new(
      organization: current_organization,
      category_identifier: category_identifier,
      file_name: file_name,
      options: {
        mode_of_transport: mot,
        group_id: upload_params[:group_id]
      }
    ).perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(
      key: category_identifier,
      url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: "attachment")
    )
  end

  private

  def upload_params
    params.permit(:async, :file, :group_id)
  end

  def for_index_json(local_charge, options = {})
    new_options = options.reverse_merge(
      methods: %i[hub_name counterpart_hub_name service_level carrier_name]
    )
    local_charge.as_json(new_options)
  end

  def download_params
    params.require(:options).permit(:mot, :group_id)
  end

  def handle_search
    query = ::Legacy::LocalCharge.where(organization: current_organization)
    query = query.where(group_id: search_params[:group_id]) if search_params[:group_id]
    query = query.search(search_params[:query]) if search_params[:query]
    if search_params[:name_desc]
      query = query.joins(:hub).order("hubs.name #{search_params[:name_desc] == "true" ? "DESC" : "ASC"}")
    end
    query
  end

  def search_params
    params.permit(:group_id,
      :page_size,
      :per_page,
      :page,
      :name_desc)
  end

  def pagination_options
    {
      page: current_page,
      per_page: (search_params[:page_size] || search_params[:per_page])&.to_f
    }.compact
  end

  def current_page
    search_params[:page]&.to_i || 1
  end
end
