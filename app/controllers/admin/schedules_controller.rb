class Admin::SchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin

  include ExcelTools

  

  def index
    @train_schedules = Schedule.where(mode_of_transport: 'train').paginate(:page => params[:page], :per_page => 100)
    @ocean_schedules = Schedule.where(mode_of_transport: 'ocean').paginate(:page => params[:page], :per_page => 100)
    @air_schedules = Schedule.where(mode_of_transport: 'air').paginate(:page => params[:page], :per_page => 100)
    response_handler({air: @air_schedules, train: @train_schedules, ocean: @ocean_schedules})
  end
  def auto_generate_schedules
    @route = Route.find(params[:route_id])
    @route.generate_weekly_schedules(params[:mot], params[:start_date], params[:end_date], params[:ordinal_array], params[:journey_length])
    response_handler(true)
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
