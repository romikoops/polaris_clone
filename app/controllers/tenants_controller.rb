# frozen_string_literal: true

class TenantsController < ApplicationController
  include Response

  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
  def index
    tenants = []
    tenants = Tenant.all.map { |t| { label: t.name, value: t } } unless Rails.env.production?
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
    response_handler(tenant: tenant)
  end

  def current
    response_handler(tenant_id: tenant.id)
  end

  private

  def tenant
    subdomain = [
      URI(request.referrer).host.split('.').first,
      ENV['DEV_SUBDOMAIN']
    ].find do |subdom|
      Tenant.exists?(subdomain: subdom)
    end
    tenant = Tenant.find_by(subdomain: subdomain)
  end
end
