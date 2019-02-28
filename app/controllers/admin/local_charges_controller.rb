# frozen_string_literal: true

class Admin::LocalChargesController < ApplicationController # rubocop:disable Style/ClassAndModuleChildren
  include ExcelTools

  def hub_charges # rubocop:disable Metrics/AbcSize
    hub = Hub.find(params[:id])
    charges = hub.local_charges
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
      charges: hub.local_charges,
      customs: hub.customs_fees,
      serviceLevels: service_levels,
      counterpartHubs: counter_part_hubs
    }
    response_handler(resp)
  end

  def edit
    data = params[:data].as_json
    id = data.delete('id')
    local_charge = LocalCharge.find(id)
    local_charge.update(fees: data['fees'])
    response_handler(local_charge)
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
    file = upload_params[:file].tempfile
    identifier = 'LocalCharges'

    options = { tenant: current_tenant,
                specific_identifier: identifier,
                file_or_path: file }
    uploader = ExcelDataServices::Loader::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def download
    mot = download_params[:mot]
    key = 'local_charges'
    klass_identifier = 'LocalCharges'
    file_name = "#{current_tenant.subdomain.downcase}__local_charges_#{mot}"

    options = { tenant: current_tenant, specific_identifier: klass_identifier, file_name: file_name }
    downloader = ExcelDataServices::Loader::Downloader.new(options)

    document = downloader.perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(key: key, url: rails_blob_url(document.file, disposition: 'attachment'))
  end

  private

  def upload_params
    params.permit(:file)
  end

  def download_params
    params.require(:options).permit(:mot)
  end
end
