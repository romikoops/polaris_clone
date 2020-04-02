# frozen_string_literal: true

require 'scientist'
class TruckingAvailabilityController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    @base_pricing_enabled = current_scope.fetch(:base_pricing)
    trucking_pricings = find_trucking_pricings
    truck_type_object = Hash.new { |h, k| h[k] = [] }
    hub_ids = []
    trucking_pricings.each do |trucking_pricing|
      hub_id = trucking_pricing.hub_id
      hub_ids << hub_id

      truck_type = trucking_pricing.truck_type
      truck_type_object[hub_id] << trucking_pricing.truck_type unless truck_type_object[hub_id].include?(truck_type)
    end
    nexus_ids = Hub.where(id: hub_ids, sandbox: @sandbox).pluck(:nexus_id).uniq

    response = build_response_hash(trucking_pricings, nexus_ids, hub_ids, truck_type_object)
    response_handler(response)
  end

  private

  def build_response_hash(trucking_pricings, nexus_ids, hub_ids, truck_type_object)
    {
      trucking_available: !trucking_pricings.empty?,
      nexus_ids: nexus_ids.compact,
      hub_ids: hub_ids.compact,
      truck_type_object: truck_type_object
    }.deep_transform_keys { |k| k.to_s.camelize(:lower) }
  end

  def find_trucking_pricings
    args = {
      tenant_id: params[:tenant_id],
      load_type: params[:load_type],
      address: Address.new(latitude: params[:lat], longitude: params[:lng]).reverse_geocode,
      hub_ids: params[:hub_ids].split(',').map(&:to_i),
      carriage: params[:carriage],
      klass: Trucking::Trucking,
      sandbox: @sandbox,
      order_by: @base_pricing_enabled ? 'group_id' : 'user_id'
    }
    Trucking::Queries::Availability.new(args).perform
  end
end
