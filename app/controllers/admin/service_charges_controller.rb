class Admin::ServiceChargesController < ApplicationController
  include ExcelTools
  include Response
  before_action :require_login_and_role_is_admin

  

  def index
    # @import_charges = ServiceCharge.where(trade_direction: "import")
    @service_charges = ServiceCharge.all
    response_handler(@service_charges)
    # @export_charges = ServiceCharge.where(trade_direction: "export")
  end
  def update
    @sc = ServiceCharge.find(params[:id])
    updates = params[:data]

    @sc.update_attributes(sanitized_params)
    @sc.save!
    response_handler(@sc)
  end
  def edit
    data = params[:data].as_json
    id = data["_id"]
    data.delete("_id")
    update_item('localCharges', {"_id" => id}, data)
    response_handler(data)
  end

  def overwrite
    if params[:file]
      req = {'xlsx' => params[:file]}
      overwrite_local_charges(req, current_user)
      response_handler(true)
    else
      response_handler(false)
    end
  end

  private

  def sanitized_params
    params.require(:data).permit(
      :hub_id, :effective_date, :expiration_date, :location, :misc_fees,
      terminal_handling_cbm: [:value, :currency, :trade_direction],
      terminal_handling_ton: [:value, :currency, :trade_direction],
      terminal_handling_min: [:value, :currency, :trade_direction],
      lcl_service_cbm: [:value, :currency, :trade_direction],
      lcl_service_ton: [:value, :currency, :trade_direction],
      lcl_service_min: [:value, :currency, :trade_direction],
      isps: [:value, :currency, :trade_direction],
      exp_declaration: [:value, :currency, :trade_direction],
      extra_hs_code: [:value, :currency, :trade_direction],
      doc_fee: [:value, :currency, :trade_direction],
      liner_service_fee: [:value, :currency, :trade_direction],
      vgm_fee: [:value, :currency, :trade_direction], 
      documentation_fee: [:value, :currency, :trade_direction],
      handling_fee: [:value, :currency, :trade_direction],
      customs_clearance: [:value, :currency, :trade_direction],
      cfs_terminal_charges: [:value, :currency, :trade_direction]
    )
  end



  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end