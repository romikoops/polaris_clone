# frozen_string_literal: true

class Admin::PricingsController < ApplicationController
  include ExcelTools
  include PricingTools
  include ItineraryTools
  before_action :require_login_and_role_is_admin

  def index
    @tenant_pricings = {} # get_tenant_path_pricings(current_user.tenant_id) TODO: remove?
    @transports = TransportCategory.all.uniq
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    pricings = Pricing.where(tenant_id: current_user.tenant_id).order(updated_at: :desc)
    detailed_itineraries = itineraries.map(&:as_pricing_json)
    @pricings = pricings.map(&:as_json)
    last_updated = pricings.first.updated_at

    response_handler(itineraries: itineraries, detailedItineraries: detailed_itineraries, tenant_pricings: @tenant_pricings, pricings: @pricings, transportCategories: @transports, lastUpdate: last_updated)
  end

  def client
    @pricings = get_user_pricings(params[:id])
    @client = User.find(params[:id])

    response_handler(userPricings: @pricings, client: @client)
  end

  def route
    itinerary = Itinerary.find(params[:id])
    pricings = itinerary.pricings.where(user_id: nil).map { |pricing| { pricing: pricing, transport_category: pricing.transport_category } } # get_itinerary_pricings_hash(itinerary.id)
    user_pricings = itinerary.pricings.where.not(user_id: nil).map { |pricing| { pricing: pricing, transport_category: pricing.transport_category, user_id: pricing.user_id } }
    stops = itinerary.stops.map { |s| { stop: s, hub: s.hub } }
    response_handler(itineraryPricingData: pricings, itinerary: itinerary.as_options_json, stops: stops, userPricings: user_pricings)
  end

  def update_price
    pricing_to_update = Pricing.find(params[:id])
    new_pricing_data = params.as_json
    new_pricing_data.delete("controller")
    new_pricing_data.delete("subdomain_id")
    new_pricing_data.delete("action")
    new_pricing_data.delete("id")
    new_pricing_data.delete("created_at")
    new_pricing_data.delete("updated_at")
    new_pricing_data.delete("load_type")
    new_pricing_data.delete("currency")
    pricing_details = new_pricing_data.delete("data")
    pricing_exceptions = new_pricing_data.delete("exceptions")
    pricing_to_update.update(new_pricing_data)
    pricing_details.each do |shipping_type, pricing_detail_data|
      currency = pricing_detail_data.delete("currency")
      pricing_detail_params = pricing_detail_data.merge(shipping_type: shipping_type, tenant: current_user.tenant)
      range = pricing_detail_params.delete("range")
      pricing_detail = pricing_to_update.pricing_details.find_or_create_by(shipping_type: shipping_type, tenant: current_user.tenant)
      pricing_detail.update!(pricing_detail_params)
      pricing_detail.update!(range: range, currency_name: currency) # , external_updated_at: external_updated_at)
    end

    pricing_exceptions.each do |pricing_exception_data|
      pricing_details = pricing_exception_data.delete("data")
      pricing_exception = pricing_to_update.pricing_exceptions.where(pricing_exception_data).first_or_create(pricing_exception_data.merge(tenant: current_user.tenant))
      pricing_details.each do |shipping_type, pricing_detail_data|
        currency = pricing_detail_data.delete("currency")
        range = pricing_detail_data.delete("range")
        pricing_detail_params = pricing_detail_data.merge(shipping_type: shipping_type, tenant: current_user.tenant)
        pricing_detail = pricing_exception.pricing_details.where(pricing_detail_params).first_or_create!(pricing_detail_params)
        pricing_detail.update!(range: range, currency_name: currency)
      end
    end
    response_handler(pricing: pricing_to_update.as_json, transport_category: pricing_to_update.transport_category)
  end

  def destroy
    delete_pricing(params[:id])
    response_handler({})
  end

  def download_pricings
    options = params[:options].as_json.deep_symbolize_keys!
    options[:tenant_id] = current_user.tenant_id
    url = DocumentService::PricingWriter.new(options).perform
    response_handler(url: url, key: "pricing")
  end

  def overwrite_main_lcl_carriage
    if params[:file] && params[:file] != "null"
      req = { "xlsx" => params[:file] }
      results = overwrite_freight_rates(req, current_user, false)
      response_handler(results)
    else
      response_handler(false)
    end
  end

  def overwrite_main_fcl_carriage
    if params[:file] && params[:file] != "null"
      req = { "xlsx" => params[:file] }
      results = overwrite_freight_rates(req, current_user, false)
      response_handler(results)
    else
      response_handler(false)
    end
  end

  def eliminate_user_pricings(prices, itineraries)
    results = []
    itineraries.each do |itin|
      if !prices || prices&.empty?
        results.push(itin)
      else
        prices.each do |_k, v|
          splits = v.split("_")
          hub1 = splits[0].to_i
          hub2 = splits[1].to_i
          results.push(itin) if itin["first_stop_id"] == hub1 && itin["destination_stop_id"] == hub2
        end
      end
    end
    results
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      redirect_to root_path
    end
  end

  def update_params
    params.require(:update).permit(
      :wm, :heavy_wm, :heavy_kg
    )
  end

  def itinerary_pricing_exists?(args)
    Itinerary.find_by(args).nil?
  end
end
