# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class OrganizationsGroupsController < ApiController
      def index
        organizations_groups = Groups::Group.where(organization_id: current_organization.id)
        render json: OrganizationsGroupSerializer.new(organizations_groups)
      end
    end
  end
end
