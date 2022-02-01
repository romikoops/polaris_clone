# frozen_string_literal: true

class Admin::LocalChargesController < Admin::AdminBaseController
  include ExcelTools

  def hub_charges
    charges = Legacy::LocalCharge.where(hub: hub).current
    service_levels = Legacy::TenantVehicle.where(id: charges.select(:tenant_vehicle_id)).map do |tenant_vehicle|
      {
        label: tenant_vehicle.full_name,
        value: tenant_vehicle.id
      }
    end

    counter_part_hubs = charges.pluck(:counterpart_hub_id).map do |counterpart_hub_id|
      { label: counterpart_hub_id ? Legacy::Hub.find(counterpart_hub_id).name : "None", value: counterpart_hub_id }
    end
    groups = Groups::Group.where(id: charges.select(:group_id)).map do |group|
      { label: group.name, value: group.id }
    end

    resp = {
      hub_id: hub.id,
      charges: charges,
      customs: hub.customs_fees,
      serviceLevels: service_levels,
      groups: groups,
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
    response_local_charges = paginated_local_charges.map do |local_charge|
      for_index_json(local_charge)
    end

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
      text: "group_id:#{upload_params[:group_id] || 'all'}",
      type: "local_charges",
      options: {
        group_id: upload_params[:group_id]
      }
    )
  end

  def download
    category_identifier = "local_charges"
    mot = download_params[:mot]
    file_name = "#{current_organization.slug}__#{category_identifier}_#{mot}"

    handle_download(category_identifier: category_identifier, file_name: file_name, options: {
      mode_of_transport: mot,
      group_id: download_params[:group_id]
    })
  end

  private

  def upload_params
    params.permit(:async, :file, :group_id)
  end

  def hub_params
    params.permit(:id)
  end

  def for_index_json(local_charge, options = {})
    new_options = options.reverse_merge(
      methods: %i[hub_name counterpart_hub_name service_level carrier_name]
    )
    local_charge.as_json(new_options).merge(group_name: Groups::Group.find(local_charge.group_id).name)
  end

  def download_params
    params.require(:options).permit(:mot, :group_id)
  end

  def handle_search
    relation = ::Legacy::LocalCharge.joins(:hub)
      .left_joins(:counterpart_hub)
      .joins(tenant_vehicle: :carrier)
      .joins(:group)
      .where(organization: current_organization).where("expiration_date > ?", Time.zone.today)
    relation = relation.where(hub_id: search_params[:hub_id]) if search_params[:hub_id].present?
    relation = relation.where(group_id: search_params[:group_id]) if search_params[:group_id].present?

    {
      counterpart_hub_name: ->(query, param) { query.counterpart_search(param) },
      counterpart_hub_name_desc: ->(query, param) { query.order("counterpart_hubs_local_charges.name #{param.to_s == 'true' ? 'DESC' : 'ASC'}") },
      hub: ->(query, param) { query.hub_search(param) },
      hub_desc: ->(query, param) { query.order("hubs.name #{param.to_s == 'true' ? 'DESC' : 'ASC'}") },
      service_level: ->(query, param) { query.service_search(param) },
      service_level_desc: ->(query, param) { query.order("tenant_vehicles.name #{param.to_s == 'true' ? 'DESC' : 'ASC'}") },
      carrier: ->(query, param) { query.carrier_search(param) },
      carrier_desc: ->(query, param) { query.order("carriers.name #{param.to_s == 'true' ? 'DESC' : 'ASC'}") },
      group_name: ->(query, param) { query.where("groups_groups.name ILIKE ?", "#{param}%") },
      group_name_desc: ->(query, param) { query.order("groups_groups.name #{param.to_s == 'true' ? 'DESC' : 'ASC'}") }
    }.each do |key, lambd|
      relation = lambd.call(relation, search_params[key]) if search_params[key]
    end

    relation
  end

  def search_params
    params.permit(:group_id,
      :hub_id,
      :counterpart_hub_name,
      :counterpart_hub_name_desc,
      :hub,
      :hub_desc,
      :service_level,
      :service_level_desc,
      :carrier,
      :carrier_desc,
      :group_name,
      :group_name_desc,
      :page_size,
      :per_page,
      :page)
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

  def hub
    @hub ||= Legacy::Hub.find(hub_params[:id])
  end
end
