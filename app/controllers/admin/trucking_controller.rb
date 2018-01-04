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
    response_handler({truckingHubs: all_trucking_hubs, truckingPrices: all_trucking_prices})
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
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
  
end
