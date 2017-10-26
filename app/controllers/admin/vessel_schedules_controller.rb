class Admin::VesselSchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin

  layout 'dashboard'

  def index
    @schedules = VesselSchedule.all.paginate(:page => params[:page], :per_page => 15)
  end

  def overwrite
    old_ids = VesselSchedule.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(vessel: 'VESSEL', voyage_code: 'VOYAGE_CODE', from: 'FROM', to: 'TO', eta: 'ETA', ets: 'ETS')

    schedules.each do |vessel_schedule|
      vs = VesselSchedule.find_or_create_by(vessel_schedule)
      new_ids << vs.id
    end

    kicked_vs_ids = old_ids - new_ids
    VesselSchedule.where(id: kicked_vs_ids).destroy_all

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