# frozen_string_literal: true

class Admin::VehicleTypesController < Admin::AdminBaseController
  def index
    if params[:itinerary_id]
      itinerary = Itinerary.find(params[:itinerary_id])
      @vehicle_types = itinerary.pricings.map(&:tenant_vehicle).uniq.map(&:with_carrier)
    else
      @vehicle_types = TenantVehicle.where(tenant_id: current_user.tenant_id).map(&:with_carrier)
    end
    response_handler(@vehicle_types)
  end
end
