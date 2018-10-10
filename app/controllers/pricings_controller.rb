# frozen_string_literal: true

class PricingsController < ApplicationController
  before_action :require_login

  def index
    tenant = current_user.tenant
    @itineraries = tenant.itineraries
    @pricings = current_user.pricings
    response = Rails.cache.fetch("#{@pricings.cache_key}/pricings_index", expires_in: 12.hours) do
      @transports = TransportCategory.all.uniq
      itineraries = @itineraries
                    .map { |itin| itin.as_user_pricing_json(current_user) }

      last_updated = @itineraries.first ? @itineraries.first.updated_at : DateTime.now
      {
        itineraries: itineraries,
        transportCategories: @transports,
        lastUpdate:          last_updated
      }
    end
    response_handler(response)
  end

  def show
    @itinerary = Itinerary.find(params[:id])
    @pricings = filter_for_dedicated_pricings(@itinerary.pricings).map(&:as_json)
    set_requested_flag(@pricings, current_user.id)
    response_handler({
      itinerary_id: params[:id],
      pricings: @pricings
    })
  end

  def request_dedicated_pricing
    new_pricing_request = JSON.parse(params[:data])
    new_pricing_request["status"] = "requested"
    @pricing_request = PricingRequest.create!(new_pricing_request)
    PricingMailer.request_email(new_pricing_request.to_h).deliver_later
    @itinerary = Pricing.find(new_pricing_request["pricing_id"]).itinerary
    @pricings = filter_for_dedicated_pricings(@itinerary.pricings).map(&:as_json)
    set_requested_flag(@pricings, new_pricing_request['user_id'])

    response_handler({
      itinerary_id: @itinerary.id,
      pricings: @pricings
    })
  end

  private

  def set_requested_flag(pricings, user_id)
    pricings.each do |pricing|
      if !PricingRequest.find_by(pricing_id: pricing["id"], user_id: user_id).nil?
        pricing["requested"] = true
      end
    end
  end

  def filter_for_dedicated_pricings(pricings)
    dedicated_pricings = pricings.select { |pricing| pricing.user_id == current_user.id }
    pricings.each do |pricing|
      next unless dedicated_pricings.select do |ded_pricing|
        ded_pricing.tenant_vehicle_id == pricing.tenant_vehicle_id &&
        ded_pricing.transport_category == pricing.transport_category
      end.empty?
      dedicated_pricings << pricing
    end
    dedicated_pricings
  end

  def require_login
    unless user_signed_in? && current_user && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = 'You are not authorized to access this section.'
      redirect_to root_path
    end
  end
end
