class Admin::LocalChargesController < ApplicationController
  include ExcelTools
  include DocumentTools
  def edit
    data = params[:data].as_json
    id = data["id"]
    data.delete("id")
    LocalCharge.find(id).update_attributes(data)
    data["id"] = id
    response_handler(data)
  end
  def edit_customs
    data = params[:data].as_json
    id = data["id"]
    data.delete("id")
    CustomsFee.find(id).update_attributes(data)
    data["id"] = id
    response_handler(data)
  end
  def download_local_charges
    url = write_local_charges_to_sheet(tenant_id: current_user.tenant_id)
    response_handler({url: url, key: 'local_charges'})
  end
  def overwrite
    if params[:file]
      req = {'xlsx' => params[:file]}
      resp = overwrite_local_charges(req, current_user)
      
      response_handler(resp)
    else
      response_handler(false)
    end
  end
end
