class Admin::HubsController < ApplicationController
  include ExcelTools
  before_action :require_login_and_role_is_admin

  layout 'dashboard'

  def index
    @ocean_hubs = Hub.ports
  end

  def set_status
    hub = Hub.find(params[:hub_id])
    hub.toggle_hub_status!

    render json: { updated_hub_status: hub.hub_status }, status: 200
  end

  def overwrite
    overwite_hubs(params)
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
