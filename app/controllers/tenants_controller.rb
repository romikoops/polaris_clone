class TenantsController < ApplicationController
  include Response
  def get_tenant
    @tenant = Tenant.find_by_subdomain(params[:name])
    # byebug
    if @tenant
      json_response(@tenant, 200)
    else
      json_response({}, 400)
    end
  end
end
