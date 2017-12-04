class Admin::ServiceChargesController < ApplicationController
  include ExcelTools
  include Response
  before_action :require_login_and_role_is_admin

  

  def index
    # @import_charges = ServiceCharge.where(trade_direction: "import")
    @service_charges = ServiceCharge.all
    handle_response(@service_charges)
    # @export_charges = ServiceCharge.where(trade_direction: "export")
  end

  def overwrite
    if params[:file]
      req = {'xlsx' => params[:file]}
      overwrite_service_charges(req)
      json_response(true, 200)
    else
      json_response(false, 200)
    end
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end