class Admin::PricingsController < ApplicationController
  include ExcelTools
  
  before_action :require_login_and_role_is_admin

  

  def index
    
    @ded_pricings = Pricing.where.not(customer_id: nil)
    @open_pricings = Pricing.where(customer_id: nil)

    @routes = []
    @open_pricings.each do |p|
      rt = p.route
      if !@routes.include? rt
         @routes.push(rt)
      end 
    end
    @ded_pricings.each do |p|
      rt = p.route
      if !@routes.include? rt
         @routes.push(rt)
      end 
    end
    response_handler({routes: @routes, pricings: {open: @open_pricings, dedicated: @ded_pricings}})
  end

  def overwrite_main_carriage
    if params[:file]  && params[:file] !='null'
      req = {'xlsx' => params[:file]}
        overwrite_dynamo_pricings(req, true)
      response_handler(true)
    else
      response_handler(false)
    end
  end

  def update_general_fee
    fee = GeneralFee.find(params[:id])
    new_fee = params[:profit_margin].to_d
    fee.update_attribute(:profit_margin, new_fee)

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
