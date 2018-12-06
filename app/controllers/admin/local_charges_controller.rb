# frozen_string_literal: true

class Admin::LocalChargesController < ApplicationController
  include ExcelTools

  def hub_charges
    hub = Hub.find(params[:id])
    charges = hub.local_charges
    service_levels = charges.map(&:tenant_vehicle).uniq.map(&:with_carrier).map do |tenant_vehicle|
      carrier_name = tenant_vehicle['carrier'] ?
      "#{tenant_vehicle['carrier']['name']} - #{tenant_vehicle['name']}" :
      tenant_vehicle['name']
      { label: carrier_name.capitalize.to_s, value: tenant_vehicle['id'] }
    end
    counter_part_hubs = charges.map(&:counterpart_hub).uniq.compact.map do |hub|
      { label: hub.name, value: hub }
    end
    resp = {
      hub_id:           params[:id],
      charges:          hub.local_charges,
      customs:          hub.customs_fees,
      serviceLevels:    service_levels,
      counterpartHubs:  counter_part_hubs
    }
    response_handler(resp)
  end

  def edit
    data = params[:data].as_json
    id = data['id']
    data.delete('id')
    local_charge = LocalCharge.find(id)
    local_charge.update_attributes(fees: data['fees'])
    response_handler(local_charge)
  end

  def edit_customs
    data = params[:data].as_json
    id = data['id']
    data.delete('id')
    customs_fee = CustomsFee.find(id)
    customs_fee.update_attributes(fees: data['fees'])
    response_handler(customs_fee)
  end

  def download_local_charges
    mot = download_params[:mot]
    file_name = "#{current_user.tenant.name}__local_charges_#{mot.downcase}"

    options = { tenant_id: current_user.tenant.id, file_name: file_name, mode_of_transport: mot }
    document = ExcelDataServices::FileWriter::LocalCharges.new(options).perform

    response_handler(key: 'local_charges', url: rails_blob_url(document.file, disposition: 'attachment'))
  end

  def overwrite
    if params[:file]
      req = { 'xlsx' => params[:file] }
      resp = ExcelTool::OverwriteLocalCharges.new(params: req, user: current_user).perform

      response_handler(resp)
    else
      response_handler(false)
    end
  end

  private

  def download_params
    params.require(:options).permit(:mot)
  end
end
