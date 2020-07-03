# frozen_string_literal: true

class MaxDimensionsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
    response = {
      max_dimensions: max_dimensions_result(aggregate: false),
      max_aggregate_dimensions: max_dimensions_result(aggregate: true)
    }.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
    response_handler(response)
  end

  private

  def max_dimensions_result(aggregate:)
    max_dimensions(aggregate: aggregate).presence || default_max_dimensions(aggregate: true)
  end

  def default_max_dimensions(aggregate:)
    dimensions = Legacy::MaxDimensionsBundle.where(organization_id: current_organization.id)
    aggregate ? dimensions.aggregate.to_max_dimensions_hash : dimensions.to_max_dimensions_hash
  end

  def max_dimensions(aggregate:)
    max_dimensions = max_dimensions_bundles(aggregate: aggregate)
    max_dimensions.group_by(&:mode_of_transport).each_with_object({}) do |(mot, mdbs), result|
      result[mot] = mdbs.each_with_object(Hash.new { |h, k| h[k] = 0.0 }) do |mdb, inner_result|
        dimensions.each do |dimension|
          inner_result[dimension] = mdb[dimension] if mdb[dimension] > inner_result[dimension]
        end
        inner_result
      end
      result
    end
  end

  def dimensions
    %i[
      length
      width
      height
      payload_in_kg
      chargeable_weight
      volume
    ]
  end

  def max_dimensions_bundles(aggregate:)
    collection = Legacy::MaxDimensionsBundle.where(
      organization: current_organization, aggregate: aggregate, mode_of_transport: modes_of_transport, cargo_class: cargo_classes
    )
    collection.where(tenant_vehicle: tenant_vehicles).or(collection.where(carrier: carriers))
  end

  def modes_of_transport
    @modes_of_transport ||= itineraries.pluck(:mode_of_transport).uniq + ['general']
  end

  def itineraries
    @itineraries ||= Legacy::Itinerary.where(id: itinerary_ids)
  end

  def cargo_classes
    @cargo_classes ||= pricings.select(:cargo_class).distinct
  end

  def pricings
    @pricings ||= Pricings::Pricing.where(itinerary: itineraries)
  end

  def tenant_vehicles
    @tenant_vehicles ||= Legacy::TenantVehicle.where(id: pricings.select(:tenant_vehicle_id))
  end

  def carriers
    @carriers ||= Legacy::Carrier.where(id: tenant_vehicles.select(:carrier_id))
  end

  def max_dimensions_params
    params.permit(:itinerary_ids)
  end

  def itinerary_ids
    max_dimensions_params[:itinerary_ids].present? ? max_dimensions_params[:itinerary_ids].split(',') : []
  end
end
