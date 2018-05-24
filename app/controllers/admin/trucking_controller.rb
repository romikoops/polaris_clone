class Admin::TruckingController < ApplicationController
  include ExcelTools
  include TruckingTools
  include DocumentTools

  before_action :require_login_and_role_is_admin

  def index
    response_handler({})
  end

  def show
    hub = Hub.find(params[:id])
    results = TruckingPricing.find_by_hub_id(params[:id])
    response_handler(hub: hub, truckingPricings: results)
  end

  def edit
    tp = TruckingPricing.find(params[:id])
    ntp = params[:pricing].as_json
    ntp.delete("id")
    tp.update_attributes(ntp)
    response_handler(tp)
  end

  def create
    data = params[:obj][:data].as_json
    meta = params[:obj][:meta].as_json
    global = params[:obj][:global].as_json
    query_holder = {}
    truckingQueries = []
    truckingPricings = []
    directions = meta["direction"] == 'either' ? ["import", "export"] : [meta["direction"]]
    truckingHubId = "#{meta["nexus_id"]}_#{meta["loadType"]}_#{current_user.tenant_id}"
    directions.each do |dir|
      if !query_holder[dir]
        query_holder[dir] = {}
      end
      data.each do |d|
        
        d.each do |dk, dv|
          query = {}
          if !query_holder[dir][dk]
            query_holder[dir][dk] = []
          end
          
          dv.each do |k,v|
            if k.include?('upper') || k.include?('lower')
              query[k] = v.clone.to_f
            else
              query[k] = v.clone
            end
          end
          query.delete("table")
          # query[:_id] = SecureRandom.uuid
          query[:modifier] = meta["subModifier"]
          query[:direction] = dir
          query[:trucking_hub_id] = truckingHubId
          
          query_holder[dir][dk] << query
        end
        
      end
    
    query_holder[dir].each do |k, v|
      p v.uniq
      query_holder[dir][k] = v.uniq[0]
      query_holder[dir][k][:_id] = SecureRandom.uuid
      truckingQueries << query_holder[dir][k]
    end

    data.each do |d|    
        d.each do |dk, dv|
          query = query_holder[dir][dk]
          
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
        end
      end
      end
    truckingPricings.each do |k|
      update_item('truckingPricings', {_id: k[:_id]}, k)
    end
    truckingQueries.each do |k|
      update_item('truckingQueries', {_id: k[:_id]}, k)
    end
    update_item('truckingHubs', {_id: truckingHubId}, {type: "#{meta["type"]}", load_type: meta["loadType"], modifier: "#{meta["modifier"]}", tenant_id: current_user.tenant_id, nexus_id: meta["nexus_id"]})
    
    response_handler(truckingHubId: truckingHubId)
  end

  def overwrite_zip_trucking
     if params[:file]
      req = {'xlsx' => params[:file]}
      ["import", "export"].each do |dir|
      overwrite_zipcode_weight_trucking_rates(req, current_user, dir)
      end
      response_handler(true)
    else
      response_handler(false)
    end
  end
    def overwrite_zonal_trucking_by_hub
     if params[:file]
      req = {'xlsx' => params[:file]}
      resp = overwrite_zonal_trucking_rates_by_hub(req, current_user, params[:id])
      
      response_handler(resp)
    else
      response_handler(false)
    end
  end

  def overwrite_city_trucking
    if params[:file]
      req = {'xlsx' => params[:file]}
      ["import", "export"].each do |dir|
       overwrite_city_trucking_rates(req, current_user, dir)
       end
      response_handler(true)
    else
      response_handler(false)
    end
  end

  def overwrite_zip_trucking_by_hub
    data = params
     if data["file"]
      
      if  data["direction"] == 'either'
        direction_array = ["import", "export"]
      else
        direction_array = [data["direction"]]
      end
      req = {'xlsx' => data["file"]}
      direction_array.each do |dir|
        overwrite_zipcode_trucking_rates_by_hub(req, current_user, data["id"], 'Greencarrier LTL', dir)
      end
      trucking_hub = get_item("truckingHubs", "hub_id", data["id"])
      hub = Hub.find(data["id"])
      trucking_queries = []
      trucking_pricings = []
      if trucking_hub
        trucking_queries = get_items("truckingQueries", "trucking_hub_id", trucking_hub["_id"])
        trucking_pricings = trucking_queries.map {|tq| {query: tq, pricings: get_items("truckingPricings", "trucking_query_id", tq[:_id])}}
      end
          
      response_handler(truckingHub: trucking_hub, truckingQueries: trucking_pricings, hub: hub)
    else
      response_handler(false)
    end
  end
  def download
     options = params[:options].as_json.symbolize_keys
      options[:tenant_id] = current_user.tenant_id
      url = write_trucking_to_sheet(options)
      response_handler({url: url, key: 'trucking'}) 
  end
  def overwrite_city_trucking_by_hub
    if params[:file]
      if  params["direction"] == 'either'
        direction_array = ["import", "export"]
      else
        direction_array = [params["direction"]]
      end
      req = {'xlsx' => params[:file]}
      
      direction_array.each do |dir|
       overwrite_city_trucking_rates_by_hub(req, current_user, params[:id], 'Globelink', dir)
      end
      hub = Hub.find(params["id"])
      results = TruckingPricing.find_by_hub_id(params[:id])
      response_handler(hub: hub, truckingPricings: results)
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
