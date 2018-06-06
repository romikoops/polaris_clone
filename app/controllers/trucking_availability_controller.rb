# frozen_string_literal: true

class TruckingAvailabilityController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    trucking_pricings = TruckingPricing.find_by_filter(
      tenant_id: params[:tenant_id],
      load_type: params[:load_type],
      location:  Location.new(latitude: params[:lat], longitude: params[:lng]).reverse_geocode,
      nexus_ids: params[:nexus_ids].split(",").map(&:to_i),
      carriage:  params[:carriage]
    )
    nexus_ids = trucking_pricings.map(&:nexus_id).uniq

    response = {
      trucking_available: !trucking_pricings.empty?, nexus_ids: nexus_ids
    }.deep_transform_keys { |k| k.to_s.camelize(:lower) }
    response_handler(response)
  end
end


trucking_pricings = TruckingPricing.find_by_filter( tenant_id: 13, load_type: 'cargo_item', location:  Location.new(latitude: 32.039948, longitude: 118.761585).reverse_geocode, nexus_ids: [116], carriage: 'on')