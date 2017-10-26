class Admin::HubsController < ApplicationController
  before_action :require_login_and_role_is_admin

  layout 'dashboard'

  def index
    @ocean_hubs = Location.ocean_hubs(Location.all_hubs).order(:hub_name)
    @train_hubs = Location.train_hubs(Location.all_hubs).order(:hub_name)
  end

  def set_status
    hub = Location.find(params[:location_id])
    hub.toggle_hub_status!

    render json: { updated_hub_status: hub.hub_status }, status: 200
  end

  def overwrite
    old_ids = Location.all_hubs.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    hub_rows = first_sheet.parse(
      hub_status: 'STATUS',
      location_type: 'TYPE',
      hub_name: 'NAME',
      hub_operator: 'OPERATOR',
      latitude: 'LATITUDE',
      longitude: 'LONGITUDE',
      country: 'COUNTRY',
      geocoded_address: 'FULL_ADDRESS',
      hub_address_details: 'ADDRESS_DETAILS',
      )

    hub_rows.each do |hub_row|
      hub_row[:location_type] = "hub_#{hub_row[:location_type].downcase}"
      hub = Location.find_or_create_by(location_type: hub_row[:location_type], hub_name: hub_row[:hub_name])
      new_ids << hub.id
      hub.update_attributes(hub_row)
    end

    kicked_hub_ids = old_ids - new_ids
    Location.where(id: kicked_hub_ids).destroy_all

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
