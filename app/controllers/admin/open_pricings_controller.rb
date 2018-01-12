class Admin::OpenPricingsController < ApplicationController
  include ExcelTools

  before_action :require_login_and_role_is_admin

  def index
    @pricings = Pricing.where(customer_id: nil)
    
    @routes = []
    @pricings.each do |p|
      @routes.push(p.route)
    end

    response_handler({routes: @routes, pricings: @pricings})
  end

  def overwrite_main_carriage
    if params[:file] && params[:file] !='null'
      req = {'xlsx' => params[:file]}
      overwrite_mongo_pricings(req, false)
      response_handler(true)
    else
      response_handler(false)
    end
  end

 

  private

  def require_login_and_role_is_admin
    unless unless user_signed_in? && current_user.role.name.include?("admin")
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
