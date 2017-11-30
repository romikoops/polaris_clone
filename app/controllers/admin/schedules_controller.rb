class Admin::SchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin

  include ExcelTools

  

  def index
    @train_schedules = Schedule.where(mode_of_transport: 'train').paginate(:page => params[:page], :per_page => 15)
    @ocean_schedules = Schedule.where(mode_of_transport: 'ocean').paginate(:page => params[:page], :per_page => 15)
    @air_schedules = Schedule.where(mode_of_transport: 'air').paginate(:page => params[:page], :per_page => 15)
  end

  def overwrite_trains
    overwrite_train_schedules(params)
    redirect_to :back
  end

  def overwrite_vessels
    overwrite_vessel_schedules(params)
    redirect_to :back
  end
  def overwrite_air
    overwrite_air_schedules(params)
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
