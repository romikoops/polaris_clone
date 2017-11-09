class Admin::TrainSchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin
  include ExcelTools

  layout 'dashboard'

  def index
    @schedules = Schedule.where(mode_of_transport: 'train').paginate(:page => params[:page], :per_page => 15)
  end

  def overwrite
    overwrite_train_schedules(params)
    redirect_to :back
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end

  def get_route_from_schedule(port1, port2)
    if data_box[port1] && data_box[port2]
      return  Route.where("origin_id = ? AND destination_id = ?", data_box[port1], data_box[port2])
    else
      data_box[port1] = Location.find_by_hub_name(port)
      data_box[port2] = Location.find_by_hub_name(sched.to)
     return  Route.where("origin_id = ? AND destination_id = ?", data_box[port1], data_box[port2])
   end
  end
end