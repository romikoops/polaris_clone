class TenantsController < ApplicationController
  include Response
  
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def get_tenant
    @tenant = Tenant.find_by_subdomain(params[:name])
    # 
    if @tenant
      json_response(@tenant, 200)
    else
      json_response({}, 400)
    end
  end
end
