class Admin::VehicleTypesController < ApplicationController
  before_action :require_login_and_role_is_admin

  def index
    @vehicle_types = TenantVehicle.where(tenant_id: current_user.tenant_id)
    response_handler(@vehicle_types)
  end

private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin")
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
  
end
