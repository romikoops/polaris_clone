class Admin::ServiceChargesController < ApplicationController
  include ExcelTools
  before_action :require_login_and_role_is_admin

  

  def index
    # @import_charges = ServiceCharge.where(trade_direction: "import")
    @service_charges = ServiceCharge.all
    # @export_charges = ServiceCharge.where(trade_direction: "export")
  end

  def overwrite
    overwrite_service_charges(params)

    redirect_to :back
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end