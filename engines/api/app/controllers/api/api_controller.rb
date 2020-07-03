# frozen_string_literal: true

require_dependency 'api/application_controller'

module Api
  class ApiController < ApplicationController
    include ErrorHandler
    include Pagination

    rescue_from ActiveRecord::RecordNotFound, ActionController::ParameterMissing, with: :error_handler

    skip_before_action :verify_authenticity_token
    before_action :doorkeeper_authorize!
    helper_method :current_user

    private

    def current_user
      @current_user ||= ::Authentication::User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def organization_id
      params[:organization_id]
    end

    def organization_user
      current_user.becomes(::Organizations::User)
    end

    def current_organization
      ::Organizations.current_id = organization_id
      @current_organization ||= ::Organizations::Organization.find(organization_id)
    end

    def user_organization
      current_user.organization if current_user.is_a? Organizations::User
    end

    def default_organization
      organizations = Organizations::Organization.joins(:memberships)
      .where(organizations_memberships: {user_id: current_user}).first
    end

    #def set_sandbox
    #  @sandbox = ::Tenants::Sandbox.find_by(id: request.headers[:sandbox])
    #end

    def current_scope
      @current_scope ||= ::OrganizationManager::ScopeService.new(
        target: current_user,
        organization: current_organization
      ).fetch
    end

    def doorkeeper_authorize!
      super(:public, :admin)
    end
  end
end
