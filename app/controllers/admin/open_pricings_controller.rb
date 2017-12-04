class Admin::OpenPricingsController < ApplicationController
  include ExcelTools

  before_action :require_login_and_role_is_admin

  

  def index
    @pricings = Pricing.where(customer_id: nil)
    @routes = []
    @pricings.each do |p|
      @routes.push(p.route)
    end
  end

  def overwrite_main_carriage
    overwrite_main_carriage_rates(params)

    redirect_to :back
  end

  def overwrite_trucking
    overwrite_trucking_rates(params)

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
