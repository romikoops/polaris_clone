class Admin::ServiceChargesController < ApplicationController
  before_action :require_login_and_role_is_admin

  layout 'dashboard'

  def index
    @import_charges = ServiceCharge.where(trade_direction: "import")
    @export_charges = ServiceCharge.where(trade_direction: "export")
  end

  def overwrite
    old_ids = ServiceCharge.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    service_charge_rows = first_sheet.parse(
        trade_direction: 'TRADE_DIRECTION',
        container_size_class: 'CONTAINER_SIZE',
        handling_documentation: 'HANDLING_DOCUMENTATION',
        equipment_management_charges: 'EQUIPMENT_MANAGEMENT_CHARGES',
        carrier_security_fee: 'CARRIER_SECURITY_FEE',
        verified_gross_mass: 'VERIFIED_GROSS_MASS',
        hazardous_cargo: 'HAZARDOUS_CARGO',
        add_imo_position: 'ADD_IMO_POSITION',
        export_pickup_charge: 'EXPORT_PICKUP_CHARGE',
        import_drop_off_charge: 'IMPORT_DROP_OFF_CHARGE'
      )

    service_charge_rows.each do |service_charge_row|
      service_charge_row.each do |k, v|
        service_charge_row[k] = 0 if v == "-"
        service_charge_row[k] = 0 if v.nil?
      end
      sc = ServiceCharge.find_or_create_by(service_charge_row)
      new_ids << sc.id
    end

    kicked_sc_ids = old_ids - new_ids
    ServiceCharge.where(id: kicked_sc_ids).destroy_all

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