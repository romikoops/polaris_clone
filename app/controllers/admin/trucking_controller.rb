class Admin::TruckingController < ApplicationController
  include ExcelTools
  include TruckingTools
  include MongoTools
  
  before_action :require_login_and_role_is_admin
  def index
    client = get_client
    all_trucking_hubs = get_items_fn(client, 'truckingHubs', "tenant_id", current_user.tenant_id)
    all_trucking_nexuses = all_trucking_hubs.map {|th| {trucking: th, nexus: Location.find(th["nexus_id"])}}
    response_handler({truckingNexuses: all_trucking_nexuses, nexuses: Location.where(location_type: "nexus")})
  end

  def show
    trucking_hub = get_item("truckingHubs", "_id", params[:id])
    trucking_queries = get_items("truckingQueries", "trucking_hub_id", params[:id])
    trucking_pricings = trucking_queries.map {|tq| {query: tq, pricings: get_items("truckingPricings", "trucking_query_id", tq[:_id])}}
    # byebug
    response_handler(truckingHub: trucking_hub, truckingQueries: trucking_pricings)
  end
  def create
    data = params[:obj][:data].as_json
    meta = params[:obj][:meta].as_json
    global = params[:obj][:global].as_json
    truckingQueries = []
    truckingPricings = []
    directions = meta["direction"] == 'either' ? ["import", "export"] : [meta["direction"]]
    truckingHubId = "#{meta["nexus_id"]}_#{meta["loadType"]}_#{current_user.tenant_id}"
    directions.each do |dir|
    data.each do |d|
        d.each do |dk, dv|
          query = {}
          dv.each do |k,v|
              if k.include?('upper') || k.include?('lower')
                query[k] = v.clone.to_f
              else
                query[k] = v.clone
              end
            end
          query.delete("table")
          query[:_id] = SecureRandom.uuid
          query[:modifier] = meta["subModifier"]
          query[:direction] = dir
          query[:trucking_hub_id] = truckingHubId
          dv["table"].each_with_index do |dt, i|
            
            tmp = {}
            dt.each do |k,v|
              if k.include?('min') || k.include?('max')
                tmp[k] = v.clone.to_f
              else
                tmp[k] = v.clone
              end
            end
            tmp[:_id] = SecureRandom.uuid
            tmp["type"] = dk
            tmp["trucking_hub_id"] = truckingHubId
            tmp["trucking_query_id"] = query[:_id]
            tmp["tenant_id"] = current_user.tenant_id
            truckingPricings << tmp
          end
          truckingQueries << query
        end
      end
    end
    truckingPricings.each do |k|
      update_item('truckingPricings', {_id: k[:_id]}, k)
    end
    truckingQueries.each do |k|
      update_item('truckingQueries', {_id: k[:_id]}, k)
    end
    update_item('truckingHubs', {_id: truckingHubId}, {type: "#{meta["type"]}", load_type: meta["loadType"], modifier: "#{meta["modifier"]}", tenant_id: current_user.tenant_id})
    tenant = current_user.tenant
    nexus = Location.find(meta["mexus_id"])
    update_type = meta["loadtype"] === 'lcl' ? :cargo_item : :container
    TruckingAvailability.update_hubs_trucking_availability!(tenant, [{        
      values: [nexus.name],
      options: {
        load_type: update_type
      }
    }])
    nexus.update_trucking_availability!({id: tenant.id})
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
