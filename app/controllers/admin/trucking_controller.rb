class Admin::TruckingController < ApplicationController
  include ExcelTools
  include TruckingTools
  include MongoTools
  
  before_action :require_login_and_role_is_admin
  def index
    client = get_client
    all_trucking_hubs = get_items_fn(client, 'truckingHubs', "tenant_id", current_user.tenant_id)
    all_trucking_prices = {}

    all_trucking_hubs.each do |th|
      tp = get_item_fn(client, 'truckingTables', "_id", th["table"])
      all_trucking_prices[th["_id"]] = tp
    end
    nexuses = Location.where(location_type: 'nexus')
    response_handler({truckingHubs: all_trucking_hubs, truckingPrices: all_trucking_prices, nexuses: nexuses})
  end
  def create
    data = params[:obj][:data].as_json
    meta = params[:obj][:meta].as_json
    global = params[:obj][:global].as_json
    byebug
    pricingKeys = {}
    pricings = {}
    truckingHubId = "#{meta["nexus_id"]}_#{current_user.tenant_id}"
    data.each do |d|
      d.each do |dk, dv|
        dv["table"].each_with_index do |dt, i|
          pricingKey = "#{meta["nexus_id"]}_#{dk}_#{i}_#{current_user.tenant_id}"
          pricingId = "#{meta["nexus_id"]}_#{i}_#{current_user.tenant_id}" 
          pricings[pricingKey] = {"variable" => dt["fees"], "fixed" => global}
          tmp = dt
          tmp.delete("fees")
          tmp["trucking_hub_id"] = truckingHubId
          tmp["tenant_id"] = current_user.tenant_id
          if meta["loadType"] == 'lcl'
            tmp["lcl"]["default"] = pricingKey
          else
            tmp["fcl"][dk] = pricingKey
          end
          pricingKeys[pricingId] = tmp
        end
      end
    end
    truckingTable = "#{meta["nexus_id"]}_#{meta["loadType"]}_#{current_user.tenant_id}" 
   pricings.each do |k, v|
    update_item('truckingPricings', {_id: k}, v)
   end
   pricingKeys.each do |k, v|
    update_item('truckingQueries', {_id: k}, v)
   end
    update_item('truckingHubs', {_id: "#{meta["nexus_id"]}"}, {type: "#{meta["type"]}", modifier: "#{meta["modifier"]}", table: truckingTable, tenant_id: current_user.tenant_id})
  end
  def overwrite_zip_trucking
     if params[:file]
      req = {'xlsx' => params[:file]}
      overwrite_trucking_rates(req)
      response_handler(true)
    else
      response_handler(false)
    end
  end
   def overwrite_city_trucking
     if params[:file]
      req = {'xlsx' => params[:file]}
       overwrite_city_trucking_rates(req)
      response_handler(true)
    else
      response_handler(false)
    end
  end
  

 private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
  
end
