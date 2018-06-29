# frozen_string_literal: true

class Admin::LocalChargesController < ApplicationController
  include ExcelTools

  def edit
    data = params[:data].as_json
    id = data["id"]
    data.delete("id")
    local_charge = LocalCharge.find(id)
    local_charge.update_attributes(fees: data["fees"])
    response_handler(local_charge)
  end

  def edit_customs
    data = params[:data].as_json
    id = data["id"]
    data.delete("id")
    customs_fee = CustomsFee.find(id)
    customs_fee.update_attributes(fees: data["fees"])
    response_handler(customs_fee)
  end

  def download_local_charges
    options = params[:options].as_json.deep_symbolize_keys!
    options[:tenant_id] = current_user.tenant_id
    url = DocumentService::LocalChargesWriter.new(options).perform
    response_handler(url: url, key: "local_charges")
  end

  def overwrite
    if params[:file]
      req = { "xlsx" => params[:file] }
      resp = ExcelTool::OverwriteLocalCharges.new(params: req, user: current_user).perform

      response_handler(resp)
    else
      response_handler(false)
    end
  end
end
