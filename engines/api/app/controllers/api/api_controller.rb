# frozen_string_literal: true

require_dependency "api/application_controller"

module Api
  class ApiController < ApplicationController
    API_HOST = "api.itsmycargo.com"
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
      @current_user ||= if doorkeeper_token
        user_id = doorkeeper_token.resource_owner_id
        ::Users::User.find_by(id: user_id) || ::Users::Client.find_by(id: user_id)
      end
    end

    def organization_id
      return @organization_id if defined?(@organization_id)

      @organization_id ||= begin
        org_id = params[:organization_id] if params[:organization_id]

        org_id ||= begin
          Organizations::Domain.where(domain: organization_domain).pluck(:organization_id).first
        end

        org_id
      end
    end

    def set_organization_id
      ::Organizations.current_id = organization_id
    end

    def organization_user
      current_user&.becomes(::Users::Client)
    end

    def current_organization
      @current_organization ||= ::Organizations::Organization.find(organization_id)
    end

    def user_organization
      current_user.organization if current_user.is_a? Users::Client
    end

    def default_organization
      current_user.memberships.first
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

    def organization_domain
      @organization_domain ||= begin
        domains = [
          URI(request.referrer.to_s).host,
          request.host,
          Rails.env.production? ? nil : ENV.fetch("DEFAULT_TENANT", "demo.local")
        ]

        domains.push(parse_saco_idp)
        domains.compact.flatten.find { |domain| Organizations::Domain.exists?(domain: domain) }
      end
    end

    def parse_saco_idp
      forwarded_host = request.headers["X-Forwarded-Host"]
      return if forwarded_host.nil?

      forwarded_host.split(",").map(&:strip).reject { |host| host == API_HOST }
    end

    def referer
      URI(request.referrer.to_s)
    end

    def target_groups(target:)
      OrganizationManager::GroupsService.new(target: target, organization: current_organization).fetch
    end

    def doorkeeper_application
      @doorkeeper_application ||= doorkeeper_token.application
    end

    def organization_results
      @organization_results ||= Journey::Result.joins(result_set: :query)
        .where(
          journey_result_sets: {status: "completed"},
          journey_queries: {billable: true, organization_id: current_organization.id}
        )
    end
  end
end
