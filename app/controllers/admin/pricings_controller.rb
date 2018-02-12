class Admin::PricingsController < ApplicationController
  include ExcelTools
  include PricingTools
  include ItineraryTools

  before_action :require_login_and_role_is_admin

  def index
    # @ded_pricings = Pricing.where.not(customer_id: nil)
    # @open_pricings = Pricing.where(customer_id: nil)
    @pricings = get_tenant_pricings_hash(current_user.tenant_id)
    @tenant_pricings = get_tenant_path_pricings(current_user.tenant_id)
    @transports = TransportCategory.all
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    detailed_itineraries = itineraries.flat_map{ |i| get_itinerary_options(i)}
    
    response_handler({itineraries: detailed_itineraries, tenant_pricings: @tenant_pricings, pricings: @pricings, transportCategories: @transports })
  end

  def client
    @pricings = get_user_pricings(params[:id])
    @client = User.find(params[:id])
    detailed_itineraries = get_itineraries(current_user.tenant_id)
    itineraries = eliminate_user_pricings(@pricings, detailed_itineraries)
    response_handler({userPricings: @pricings, client: @client, detailedItineraries: itineraries})
  end

  def route
    pricings = get_itinerary_pricings_hash(params[:id].to_i)
    itinerary = Itinerary.find(params[:id])
    stops = itinerary.stops.map { |s| {stop: s, hub: s.hub}  }
    detailed_itineraries = get_itinerary_options(itinerary)
    response_handler({itineraryPricingData: pricings, itinerary: itinerary, stops: stops, detailedItineraries: detailed_itineraries})
  end

  def update_price
    resp = update_pricing(params[:id], params.as_json)
    new_pricing = get_item("pricings", "_id", params[:id])
    response_handler(new_pricing)
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
  def eliminate_user_pricings(prices, itineraries)
    results = []
    itineraries.each do |itin|
      prices.each do |k, v|
        splits = v.split('_')
        hub1 = splits[0].to_i
        hub2 = splits[1].to_i
        if itin["origin_stop_id"] == hub1 && itin["destination_stop_id"] == hub2
          results.push(itin)
        end
      end
    end
    return results
  end
  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
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
