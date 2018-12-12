# frozen_string_literal: true

class TenantsController < ApplicationController
  include Response

  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
  def index
    tenants = if Rails.env.production?
                []
              else
                Tenant.where("subdomain NOT LIKE '%-sandbox'").order(:subdomain).map { |t| { label: t.name, value: t } }
              end

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
    tenant = Tenant.find_by(id: Rails.env.production? ? tenant_id : params[:id])

    response_handler(tenant: tenant)
  end

  def current
    response_handler(tenant_id: tenant_id)
  end

  private

  def tenant_id
    subdomain = [
      URI(request.referrer).host.split('.').first,
      ENV.fetch('DEFAULT_TENANT', 'demo')
    ].find do |subdom|
      Tenant.exists?(subdomain: subdom)
    end

    Tenant.find_by(subdomain: subdomain)&.id
  end
end
