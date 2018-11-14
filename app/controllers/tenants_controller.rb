# frozen_string_literal: true

class TenantsController < ApplicationController
  include Response

  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
  def index
    tenants = Tenant.all.map { |t| { label: t.name, value: t } }
    response_handler(tenants)
  end

  def get_tenant
    @tenant = Tenant.find_by_subdomain(params[:name])
    if @tenant
      json_response(@tenant, 200)
    else
      json_response({}, 400)
    end
  end

  def show
    tenant_id = params[:id]
    base_url =
      case Rails.env
      when 'production'  then "#{request.referrer}tenants/#{tenant_id}"
      when 'development' then "http://localhost:3000/tenants/#{tenant_id}"
      when 'test'        then "http://localhost:3000/tenants/#{tenant_id}"
      end
    # ref = "#{request.referrer}tenants/#{tenant_id}"
    tenant = Tenant.find(tenant_id)
    response_handler(url: base_url, tenant: tenant)
  end
end
