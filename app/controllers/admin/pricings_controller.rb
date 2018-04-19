class Admin::PricingsController < ApplicationController
  include ExcelTools
  include PricingTools
  include ItineraryTools
  include DocumentTools

  before_action :require_login_and_role_is_admin

  def index
    # @ded_pricings = Pricing.where.not(customer_id: nil)
    # @open_pricings = Pricing.where(customer_id: nil)

    @tenant_pricings = {} # get_tenant_path_pricings(current_user.tenant_id) TODO: remove?
    @transports = TransportCategory.all.uniq
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    @pricings = Pricing.where(tenant_id: current_user.tenant_id).as_json
    detailed_itineraries = itineraries.map(&:as_options_json)
    
    response_handler({ itineraries: itineraries, detailedItineraries: detailed_itineraries, tenant_pricings: @tenant_pricings, pricings: @pricings, transportCategories: @transports })
  end

  def client
    @pricings = get_user_pricings(params[:id])
    @client = User.find(params[:id])
    detailed_itineraries = get_itineraries(current_user.tenant_id)
    
    itineraries = eliminate_user_pricings(@pricings, detailed_itineraries)
    response_handler({userPricings: @pricings, client: @client, detailedItineraries: itineraries})
  end

  def route
    itinerary = Itinerary.find(params[:id])
    pricings = itinerary.pricings #get_itinerary_pricings_hash(itinerary.id)
    stops = itinerary.stops.map { |s| {stop: s, hub: s.hub}  }
    detailed_itineraries = [itinerary.as_options_json]
    response_handler({itineraryPricingData: pricings, itinerary: itinerary, stops: stops, detailedItineraries: detailed_itineraries})
  end

  def update_price
    data = params.as_json
    data.delete("controller")
    data.delete("subdomain_id")
    data.delete("action")
    resp = update_pricing(params[:id], data)
    parse_and_update_itinerary_pricing_id(data)
    new_pricing = get_item("pricings", "_id", params[:id])
    response_handler(new_pricing)
  end

  def destroy
    delete_pricing(params[:id])
    response_handler({})
  end

  # TODO: Update this function
  def parse_and_update_itinerary_pricing_id(data)

    first_stop_id, last_stop_id, transport_category_id, tenant_id, load_type, load_type_detail, additional_load_type_detail = data["id"].split("_")

    itinerary_params =
      if load_type == 'fcl' && additional_load_type_detail.present?
        { additional_load_type_detail => data["id"] }
        # TODO: why?
      elsif load_type != 'fcl' && load_type_detail.present?
        { load_type_detail => data["id"] }
      else
        { "open" => data["id"] }
      end

    if itinerary_pricing_exists?(itinerary_id: data["itinerary_id"], transport_category_id: transport_category_id)
      itinerary_pricing_update(data["itinerary_id"], itinerary_params)
    else
      new_itinerary_params = {
        tenant_id: current_user.tenant_id,
        transport_category_id: data["transport_category_id"],
        itinerary_id: data["itinerary_id"]
      }.merge(itinerary_params)
      itinerary_pricing_create(new_itinerary_params)
    end

    # current_user.tenant.update_route_details

    # keys_split = data["id"].split("_")
    # itineraryPricingId = "#{keys_split[0]}_#{keys_split[1]}_#{keys_split[2]}"
    # existing_itinerary = get_item("itineraryPricings", "_id", itineraryPricingId)
    #
    # if  !existing_itinerary
    #   new_itinerary = {
    #     tenant_id: current_user.tenant_id,
    #     transport_category_id: data["transport_category_id"],
    #     itinerary_id: data["itinerary_id"]
    #   }
    #   if data["id"].include?("fcl")
    #     if keys_split.length == 7
    #       new_itinerary["#{keys_split[6]}"] = data["id"]
    #     else
    #       new_itinerary["open"] = data["id"]
    #     end
    #   else
    #     if keys_split.length == 6
    #       new_itinerary["#{keys_split[5]}"] = data["id"]
    #     else
    #       new_itinerary["open"] = data["id"]
    #     end
    #   end
    #   update_item("itineraryPricings", {"_id" => itineraryPricingId}, new_itinerary)
    # else
    #   if data["id"].include?("fcl")
    #     if keys_split.length == 7
    #       update_item("itineraryPricings", {"_id" => itineraryPricingId}, {"#{keys_split[6]}" => data["id"]})
    #     else
    #       update_item("itineraryPricings", {"_id" => itineraryPricingId}, {"open" => data["id"]})
    #     end
    #   else
    #     if keys_split.length == 6
    #       update_item("itineraryPricings", {"_id" => itineraryPricingId}, {"#{keys_split[5]}" => data["id"]})
    #     else
    #       update_item("itineraryPricings", {"_id" => itineraryPricingId}, {"open" => data["id"]})
    #     end
    #   end
    # end
    # current_user.tenant.update_route_details
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
  def download_pricings
    url = write_pricings_to_sheet(tenant_id: current_user.tenant_id)
    response_handler({url: url, key: 'pricing'})
  end

  def overwrite_main_lcl_carriage
    if params[:file]  && params[:file] !='null'
      req = {'xlsx' => params[:file]}
      results = overwrite_freight_rates(req, current_user,false)
      response_handler(results)
    else
      response_handler(false)
    end
  end

  def overwrite_main_fcl_carriage
    if params[:file]  && params[:file] !='null'
      req = {'xlsx' => params[:file]}
      results = overwrite_freight_rates(req, current_user,false)
      response_handler(results)
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
      if !prices || prices && prices.empty?
        results.push(itin)
      else
        prices.each do |k, v|
          splits = v.split('_')
          hub1 = splits[0].to_i
          hub2 = splits[1].to_i
          if itin["origin_stop_id"] == hub1 && itin["destination_stop_id"] == hub2
            results.push(itin)
          end
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
