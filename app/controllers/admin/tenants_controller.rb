# frozen_string_literal: true

module Admin
  class TenantsController < AdminBaseController
    def update
      tenant = current_tenant
      tenant.assign_attributes(tenant_params)

      raise ApplicationError::InvalidTenant unless tenant.save

      response_handler(tenant)
    end

    private

    def tenant_params
      params.require(:tenant).permit(
        emails: {
          sales: %i(ocean rail air general),
          support: %i(ocean rail air general)
        }
      )
    end
  end
end
