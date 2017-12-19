class Admin::TruckingController < ApplicationController
  include ExcelTools
  include PricingTools
  
  before_action :require_login_and_role_is_admin
  def index
    response_handler(true)
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
