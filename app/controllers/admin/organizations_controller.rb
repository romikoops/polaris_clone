# frozen_string_literal: true

module Admin
  class OrganizationsController < AdminBaseController
    def update
      theme = Organizations::Theme.find_by(organization: current_organization)
      theme.assign_attributes(organization_params)

      raise ApplicationError::InvalidTenant unless theme.save

      response_handler(current_organization)
    end

    private

    def organization_params
      params.require(:tenant).permit(
        emails: {
          sales: %i(ocean rail air general),
          support: %i(ocean rail air general)
        }
      )
    end
  end
end
