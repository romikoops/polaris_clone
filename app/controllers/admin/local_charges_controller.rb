# frozen_string_literal: true

class Admin::LocalChargesController < ApplicationController # rubocop:disable Style/ClassAndModuleChildren
  include ExcelTools

  def hub_charges # rubocop:disable Metrics/AbcSize
    hub = Hub.find_by(id: params[:id], sandbox: @sandbox)
    charges = hub.local_charges.where(sandbox: @sandbox)
    service_levels = charges.map(&:tenant_vehicle).uniq.map(&:with_carrier).map do |tenant_vehicle|
      carrier_name = if tenant_vehicle['carrier']
                       "#{tenant_vehicle['carrier']['name']} - #{tenant_vehicle['name']}"
                     else
                       tenant_vehicle['name']
                     end
      { label: carrier_name.capitalize.to_s, value: tenant_vehicle['id'] }
    end

    counter_part_hubs = charges.map(&:counterpart_hub).uniq.compact.map do |hub|
      { label: hub.name, value: hub }
    end

    resp = {
      hub_id: params[:id],
      charges: hub.local_charges.where(sandbox: @sandbox),
      customs: hub.customs_fees,
      serviceLevels: service_levels,
      counterpartHubs: counter_part_hubs
    }
    response_handler(resp)
  end

  def edit
    data = params[:data].as_json
    id = data.delete('id')
    local_charge = LocalCharge.find_by(id: id, sandbox: @sandbox)
    local_charge.update(fees: data['fees'])
    response_handler(local_charge)
  end

  def destroy
    result = LocalCharge.find(params[:id]).destroy
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
    id = data['id']
    data.delete('id')
    customs_fee = CustomsFee.find(id)
    customs_fee.update(fees: data['fees'])
    response_handler(customs_fee)
  end

  def upload
    document = Document.create!(
      text: "group_id:#{upload_params[:group_id] || 'all'}",
      doc_type: 'local_charges',
      sandbox: @sandbox,
      tenant: current_tenant,
      file: upload_params[:file]
    )

    file = upload_params[:file].tempfile
    options = { tenant: current_tenant,
                file_or_path: file,
                options: {
                  sandbox: @sandbox,
                  user: current_user,
                  group_id: upload_params[:group_id],
                  document: document
                } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def download
    mot = download_params[:mot]
    key = 'local_charges'
    klass_identifier = 'LocalCharges'
    file_name = "#{::Tenants::Tenant.find_by(legacy_id: current_tenant.id).slug}__local_charges_#{mot}"

    options = {
      tenant: current_tenant,
      specific_identifier: klass_identifier,
      file_name: file_name,
      sandbox: @sandbox,
      group_id: upload_params[:group_id]
    }
    downloader = ExcelDataServices::Loaders::Downloader.new(options)

    document = downloader.perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(key: key, url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment'))
  end

  private

  def upload_params
    params.permit(:file, :group_id)
  end

  def for_index_json(local_charge, options = {})
    new_options = options.reverse_merge(
      methods: %i(hub_name counterpart_hub_name service_level carrier_name)
    )
    local_charge.as_json(new_options)
  end

  def download_params
    params.require(:options).permit(:mot, :group_id)
  end

  def handle_search
    query = LocalCharge.all
    query = query.where(group_id: search_params[:group_id]) if search_params[:group_id]
    query = query.search(search_params[:query]) if search_params[:query]
    if search_params[:name_desc]
      query = query.joins(:hub).order(hub: { name: search_params[:name_desc] == 'true' ? :desc : :asc })
    end
    query
  end

  def search_params
    params.permit(:group_id,
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
end
