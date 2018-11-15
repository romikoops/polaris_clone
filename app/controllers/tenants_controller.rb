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
    envs = [
      URI(request.referrer).host.split('.').first,
      ENV['DEV_SUBDOMAIN']
    ]
    tenant = envs.find do |subdomain|
      t = Tenant.find_by(subdomain: subdomain)     
    end
    if tenant.nil?
      tenant = Tenant.find(params[:id])
    end
    
    response_handler(tenant: tenant)
  end
end
