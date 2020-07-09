# frozen_string_literal: true

require_dependency 'api/application_controller'

module Api
  class ApiController < ApplicationController
    include ErrorHandler
    include Pagination

    rescue_from ActiveRecord::RecordNotFound, ActionController::ParameterMissing, with: :error_handler

    skip_before_action :verify_authenticity_token
    before_action :doorkeeper_authorize!
    before_action :set_organization_id
    before_action :ensure_organization!
    helper_method :current_user

    private

    def current_user
      @current_user ||= ::Authentication::User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def organization_id
      return params[:organization_id] if params[:organization_id]

      domains = [URI(request.referer || 'demo.local').host, ENV.fetch("DEFAULT_TENANT", "demo.local")]
      Organizations::Domain.where(domain: domains).first&.organization_id
    end

    def set_organization_id
      ::Organizations.current_id = organization_id
    end

    def organization_user
      current_user&.becomes(::Organizations::User)
    end

    def current_organization
      @current_organization ||= ::Organizations::Organization.find(organization_id)
    end

    def user_organization
      current_user.organization if current_user.is_a? Organizations::User
    end

    def default_organization
      organizations = Organizations::Organization.joins(:memberships)
      .where(organizations_memberships: {user_id: current_user}).first
    end

    def current_scope
      @current_scope ||= ::OrganizationManager::ScopeService.new(
        target: current_user,
        organization: current_organization
      ).fetch
    end

    def doorkeeper_authorize!
      super(:public, :admin)
    end

    def ensure_organization!
      return head :not_found unless current_organization
    end
  end
end
