# frozen_string_literal: true

class Admin::VehicleTypesController < Admin::AdminBaseController
  def index
    if params[:itinerary_id]
      itinerary = Itinerary.find_by(id: params[:itinerary_id], sandbox: @sandbox)
      @vehicle_types = itinerary.pricings
                                .where(sandbox: @sandbox)
                                .map(&:tenant_vehicle).uniq
                                .map(&:with_carrier)
    else
      @vehicle_types = TenantVehicle.where(
        tenant_id: current_user.tenant_id,
        sandbox: @sandbox
      ).map(&:with_carrier)
    end
    response_handler(@vehicle_types)
  end
end
