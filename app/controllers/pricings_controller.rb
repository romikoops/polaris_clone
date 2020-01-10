# frozen_string_literal: true

class PricingsController < ApplicationController
  before_action :require_login

  def index
    tenant = current_user.tenant
    closed_quotation_tool = current_scope.fetch(:closed_quotation_tool)
    if closed_quotation_tool
      user_pricing_id = current_user.agency.agency_manager_id
      @pricings = tenant.pricings.where(user_id: user_pricing_id, sandbox: @sandbox)
      @itineraries = @pricings.map(&:itinerary)
    else
      @pricings = tenant.pricings.where(sandbox: @sandbox)
      @itineraries = tenant.itineraries.where(sandbox: @sandbox)
    end
    response = Rails.cache.fetch("#{@pricings.cache_key}/pricings_index", expires_in: 12.hours) do
      @transports = TransportCategory.where(sandbox: @sandbox).uniq
      itineraries = @itineraries
                    .map { |itin| itin.as_user_pricing_json(current_user) }

      last_updated = @itineraries.first ? @itineraries.first.updated_at : DateTime.now
      {
        itineraries: itineraries,
        transportCategories: @transports,
        lastUpdate: last_updated
      }
    end
    response_handler(response)
  end

  def show
    @itinerary = Itinerary.find_by(id: params[:id], sandbox: @sandbox)
    @pricings = filter_for_dedicated_pricings(@itinerary.pricings.where(sandbox: @sandbox)).map(&:as_json)
    set_requested_flag(@pricings, current_user.id)
    response_handler(
      itinerary_id: params[:id],
      pricings: @pricings
    )
  end

  def request_dedicated_pricing
    new_pricing_request = pricing_request_params.to_h.symbolize_keys
    PricingMailer.request_email(new_pricing_request).deliver_later

    new_pricing_request[:status] = 'requested'
    @pricing_request = PricingRequest.create!(new_pricing_request)

    @itinerary = Pricing.find_by(id: new_pricing_request[:pricing_id], sandbox: @sandbox).itinerary
    @pricings = filter_for_dedicated_pricings(@itinerary.pricings.where(sandbox: @sandbox)).map(&:as_json)
    set_requested_flag(@pricings, new_pricing_request[:user_id])

    response_handler(
      itinerary_id: @itinerary.id,
      pricings: @pricings
    )
  end

  private

  def set_requested_flag(pricings, user_id)
    pricings.each do |pricing|
      pricing['requested'] = true unless PricingRequest.find_by(pricing_id: pricing['id'], user_id: user_id).nil?
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

  def pricing_request_params
    params.permit(:tenant_id, :pricing_id, :user_id)
  end

  def require_login
    unless user_signed_in? && current_user && current_user.tenant_id == params[:tenant_id].to_i
      raise ApplicationError::NotAuthenticated
    end
  end
end
