# frozen_string_literal: true

class Admin::VehicleTypesController < Admin::AdminBaseController
  def index
    tenant_vehicles = Legacy::TenantVehicle.where(organization: current_organization)
    if params[:itinerary_id]
      tenant_vehicles = tenant_vehicles.where(id:
        Pricings::Pricing.where(itinerary_id: params[:itinerary_id]).select(:tenant_vehicle_id).distinct)
    end
    response_handler(tenant_vehicles.map(&:with_carrier))
  end
end
