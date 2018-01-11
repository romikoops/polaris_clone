class Admin::SchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin

  include ExcelTools

  

  def index
    tenant = Tenant.find(current_user.tenant_id)
    @train_schedules = tenant.schedules.where(mode_of_transport: 'train').paginate(:page => params[:page], :per_page => 100)
    @ocean_schedules = tenant.schedules.where(mode_of_transport: 'ocean').paginate(:page => params[:page], :per_page => 100)
    @air_schedules = tenant.schedules.where(mode_of_transport: 'air').paginate(:page => params[:page], :per_page => 100)
    @routes = Route.where(tenant_id: current_user.tenant_id)
    # 
    response_handler({air: @air_schedules, train: @train_schedules, ocean: @ocean_schedules, routes: @routes})
  end
  def auto_generate_schedules
    tenant = Tenant.find(current_user.tenant_id)
    @hub_route = HubRoute.find_by(starthub_id: params[:startHubId], endhub_id: params[:endHubId])
    mot = params[:mot].split('_')[0]
    @hub_route.generate_weekly_schedules(mot, params[:startDate], params[:endDate], params[:weekdays], params[:duration], params[:vehicleTypeId])
    @train_schedules = tenant.schedules.where(mode_of_transport: 'train').paginate(:page => params[:page], :per_page => 100)
    @ocean_schedules = tenant.schedules.where(mode_of_transport: 'ocean').paginate(:page => params[:page], :per_page => 100)
    @air_schedules = tenant.schedules.where(mode_of_transport: 'air').paginate(:page => params[:page], :per_page => 100)
    @routes = Route.where(tenant_id: current_user.tenant_id)
    response_handler({air: @air_schedules, train: @train_schedules, ocean: @ocean_schedules, routes: @routes})
  end

  def overwrite_trains
     if params[:file]
      req = {'xlsx' => params[:file]}
       overwrite_train_schedules(req)
      response_handler(true)
    else
      response_handler(false)
    end
  end

  def overwrite_vessels
     if params[:file]
      req = {'xlsx' => params[:file]}
       overwrite_vessel_schedules(req)
      response_handler(true)
    else
      response_handler(false)
    end
  end
  def overwrite_air
     if params[:file]
      req = {'xlsx' => params[:file]}
       overwrite_air_schedules(req)
      response_handler(true)
    else
      response_handler(false)
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
