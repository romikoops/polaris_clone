class Admin::TrainSchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin

  layout 'dashboard'

  def index
    @schedules = TrainSchedule.all.paginate(:page => params[:page], :per_page => 15)
  end

  def overwrite
    old_ids = TrainSchedule.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    schedules = first_sheet.parse(from: 'FROM', to: 'TO', eta: 'ETA', etd: 'ETD')

    schedules.each do |train_schedule|
      # begin
        ts = TrainSchedule.find_or_create_by(train_schedule)
        new_ids << ts.id
      # rescue => ex
      #   byebug
      # end
    end

    kicked_ts_ids = old_ids - new_ids
    TrainSchedule.where(id: kicked_ts_ids).destroy_all

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