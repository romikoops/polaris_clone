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
    # old_ids = Location.all_hubs.pluck(:id)
    # new_ids = []

    # xlsx = Roo::Spreadsheet.open(params['xlsx'])
    # first_sheet = xlsx.sheet(xlsx.sheets.first)

    # hub_rows = first_sheet.parse(
    #   hub_status: 'STATUS',
    #   hub_type: 'TYPE',
    #   hub_name: 'NAME',
    #   hub_code: 'CODE',
    #   hub_operator: 'OPERATOR',
    #   latitude: 'LATITUDE',
    #   longitude: 'LONGITUDE',
    #   country: 'COUNTRY',
    #   geocoded_address: 'FULL_ADDRESS',
    #   hub_address_details: 'ADDRESS_DETAILS'
    #   )

    # hub_type_name = {
    #   "ocean" => "Port",
    #   "air" => "Airport",
    #   "rail" => "Railway Station"
    # }

    # hub_rows.each do |hub_row|
    #   hub_row[:hub_type] = hub_row[:hub_type].downcase
    #   nexus = Location.find_or_create_by(name: hub_row[:hub_name], location_type: "nexus", latitude: hub_row[:latitude], longitude: hub_row[:longitude])

    #   if !hub_row[:hub_code] || hub_row[:hub_code] == ""
    #     hub_code = Hub.generate_hub_code(nexus, hub_row[:hub_name], hub_row[:hub_type])
    #   else
    #     hub_code = hub_row[:hub_code]
    #   end
      
    #   hub = nexus.hubs.find_or_create_by(hub_code: hub_code, location_id: nexus.id, tenant_id: current_user.tenant_id, hub_type: hub_row[:hub_type], latitude: hub_row[:latitude], longitude: hub_row[:longitude], name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}")
    #   new_ids << hub.id
    # end

    # kicked_hub_ids = old_ids - new_ids
    # Hub.where(id: kicked_hub_ids).destroy_all
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
