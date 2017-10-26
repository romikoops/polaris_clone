class Admin::OpenPricingsController < ApplicationController
  before_action :require_login_and_role_is_admin

  layout 'dashboard'

  def index
    # @general_fee = GeneralFee.first
    
    @trucking_pricing = TruckingPricing.first
    @pricings = Pricing.all_open
  end

  def overwrite_train_and_ocean
    old_ids = Pricing.all_open.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)
    pricing_rows = first_sheet.parse(
        exp_date: 'EXPIRATION_DATE',
        mode_of_transport: 'MOT',
        origin: 'ORIGIN',
        destination: 'DESTINATION',
        currency: 'CURRENCY',
        lcl_m3_ton_price: 'LCL_M3_TON',
        fcl_20f_price: 'FCL_20',
        fcl_40f_price: 'FCL_40',
        fcl_40f_hq_price: 'FCL_40HQ'
      )

    pricing_rows.each do |row|
      origin = Location.all_hubs.find_by(hub_name: row[:origin])
      destination = Location.all_hubs.find_by(hub_name: row[:destination])

      row = row.except(*[:origin, :destination]).merge(origin_id: origin.id, destination_id: destination.id, customer_id: nil)
      pr = Pricing.find_or_create_by(row)
      new_ids << pr.id
    end

    kicked_pr_ids = old_ids - new_ids
    Pricing.where(id: kicked_pr_ids).destroy_all

    redirect_to :back
  end

  def update_trucking
    pricing = TruckingPricing.find(params[:id])
    new_price = params[:trucking_price_per_km].to_d
    pricing.update_attribute(:price_per_km, new_price)

    redirect_to admin_pricings_path
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
