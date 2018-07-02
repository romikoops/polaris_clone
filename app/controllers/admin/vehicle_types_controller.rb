# frozen_string_literal: true

class Admin::VehicleTypesController < Admin::AdminBaseController

  def index
    @vehicle_types = TenantVehicle.where(tenant_id: current_user.tenant_id)
    response_handler(@vehicle_types)
  end
end
