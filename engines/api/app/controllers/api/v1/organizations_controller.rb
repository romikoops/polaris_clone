# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApiController
      def index
        organizations = Organizations::Organization.joins(:memberships)
                                                   .where(organizations_memberships: {user_id: current_user})
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
