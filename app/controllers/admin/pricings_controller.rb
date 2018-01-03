class Admin::PricingsController < ApplicationController
  include ExcelTools
  include PricingTools

  before_action :require_login_and_role_is_admin

  def index
    # @ded_pricings = Pricing.where.not(customer_id: nil)
    # @open_pricings = Pricing.where(customer_id: nil)
    @pricings = get_tenant_pricings_hash(current_user.tenant_id)
    @tenant_pricings = get_tenant_path_pricings(current_user.tenant_id)
    @transports = TransportCategory.all
    @routes = Route.where(tenant_id: current_user.tenant_id)
    @hub_routes = @routes.flat_map(&:hub_routes)
    detailed_routes = @routes.map do |route| 
      route.detailed_hash(
        nexus_names: true
      )
    end
    response_handler({routes: detailed_routes, tenant_pricings: @tenant_pricings, pricings: @pricings, transportCategories: @transports, hubRoutes: @hub_routes })
  end

  def client
    @pricings = get_user_pricings(params[:id])
    @client = User.find(params[:id])
    response_handler({userPricings: @pricings, client: @client})
  end

  def route
    @pricings = get_route_pricings_hash(params[:id].to_i)
    @route = Route.find(params[:id])
    response_handler({routePricingData: @pricings, route: @route})
  end

  def update_price
    resp = update_pricing(params[:id], params.as_json)
  end

  # def overwrite_main_carriage
  #   if params[:file]  && params[:file] !='null'
  #     req = {'xlsx' => params[:file]}
  #     overwrite_mongo_pricings(req, true)
  #     response_handler(true)
  #   else
  #     response_handler(false)
  #   end
  # end

  def overwrite_main_lcl_carriage
    if params[:file]  && params[:file] !='null'
      req = {'xlsx' => params[:file]}
      overwrite_mongo_lcl_pricings(req, true)
      response_handler(true)
    else
      response_handler(false)
    end
  end

  def overwrite_main_fcl_carriage
    if params[:file]  && params[:file] !='null'
      req = {'xlsx' => params[:file]}
      overwrite_mongo_fcl_pricings(req, true)
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
  def update_params
    params.require(:update).permit(
      :wm, :heavy_wm, :heavy_kg
    )
  end

end
