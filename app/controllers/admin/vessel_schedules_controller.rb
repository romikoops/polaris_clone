class Admin::VesselSchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin

  

  def index
    @schedules = Schedule.where(mode_of_transport: 'ocean').paginate(:page => params[:page], :per_page => 15)
  end

  def overwrite
    overwrite_vessel_schedules(params)
    redirect_to :back
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
