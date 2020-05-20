# frozen_string_literal: true

require_dependency 'api/application_controller'

module Api
  class ApiController < ApplicationController
    include ErrorHandler
    include Pagination

    rescue_from ActiveRecord::RecordNotFound, ActionController::ParameterMissing, with: :error_handler

    skip_before_action :verify_authenticity_token
    before_action :doorkeeper_authorize!
    before_action :set_sandbox
    helper_method :current_user

    private

    def current_user
      @current_user ||= ::Tenants::User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def current_tenant
      @current_tenant ||= ::Tenants::Tenant.find_by(id: params[:tenant_id] || params[:id]) || current_user.tenant
    end

    def set_sandbox
      @sandbox = ::Tenants::Sandbox.find_by(id: request.headers[:sandbox])
    end

    def current_scope
      @current_scope ||= ::Tenants::ScopeService.new(
        target: current_user,
        tenant: current_tenant
      ).fetch
    end

    def doorkeeper_authorize!
      super(:public, :admin)
    end
  end
end
