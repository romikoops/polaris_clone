# frozen_string_literal: true

module Admin
  class TenantsController < AdminBaseController
    def update
      tenant = current_user.tenant
      tenant.assign_attributes(tenant_params)

      if tenant.save
        response_handler(tenant)
      else
        raise # custom application error
      end
    end

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
