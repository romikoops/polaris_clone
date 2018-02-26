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
    truckingQueries = []
    truckingPricings = []
    truckingHubId = "#{meta["nexus_id"]}_#{meta["loadType"]}_#{current_user.tenant_id}"
    data.each do |d|
      d.each do |dk, dv|
        query = dv.clone
        query.delete("table")
        query[:_id] = SecureRandom.uuid
        query[:modifier] = meta["subModifier"]
        query[:trucking_hub_id] = truckingHubId
        dv["table"].each_with_index do |dt, i|
          
          tmp = dt.clone
          
          tmp[:_id] = SecureRandom.uuid
          tmp["type"] = dk
          tmp["direction"] = meta["direction"]
          tmp["trucking_hub_id"] = truckingHubId
          tmp["trucking_pricing_id"] = query[:_id]
          tmp["tenant_id"] = current_user.tenant_id
          truckingPricings << tmp
        end
        truckingQueries << query
      end
    end

    truckingPricings.each do |k|
      update_item('truckingPricings', {_id: k[:_id]}, k)
    end
    truckingQueries.each do |k|
      update_item('truckingQueries', {_id: k[:_id]}, k)
    end
    update_item('truckingHubs', {_id: truckingHubId}, {type: "#{meta["type"]}", load_type: meta["loadType"], modifier: "#{meta["modifier"]}", tenant_id: current_user.tenant_id})
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
