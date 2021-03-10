# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApiController
      skip_before_action :ensure_organization!, only: %i[index scope countries]
      skip_before_action :doorkeeper_authorize!, only: %i[show]

      def show
        render json: OrganizationSerializer.new(current_organization)
      end

      def index
        organizations = Organizations::Organization.where(id: current_user.memberships.select(:organization_id))
        organizations = organizations.includes(:theme)
        decorated_organizations = OrganizationDecorator.decorate_collection(organizations)
        render json: OrganizationSerializer.new(decorated_organizations)
      end

      def scope
        scope = OrganizationManager::ScopeService.new(organization: organization, target: current_user).fetch

        render json: scope
      end

      def countries
        countries = Legacy::Hub.where(organization_id: organization.id).collect(&:country).uniq
        render json: CountrySerializer.new(countries)
      end

      private

      def organization
        Organizations::Organization.find(params[:id])
      end
    end
  end
end
