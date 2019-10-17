# frozen_string_literal: true

require_dependency 'api/application_controller'

module Api
  class ApiController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :set_sandbox
    helper_method :current_user

    private

    def current_user
      @current_user ||= ::Tenants::User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def current_tenant
      @current_tenant ||= ::Tenants::Tenant.find_by(id: params[:tenant_id] || params[:id])
    end

    def set_sandbox
      @sandbox = ::Tenants::Sandbox.find_by(id: request.headers[:sandbox])
    end
  end
end
