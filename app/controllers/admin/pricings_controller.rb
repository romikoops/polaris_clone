# frozen_string_literal: true

class Admin::PricingsController < Admin::AdminBaseController
  include ExcelTools
  include PricingTools
  include ItineraryTools

  def index
    tenant = current_user.tenant
    @itineraries = tenant.itineraries
    response = Rails.cache.fetch("#{@itineraries.cache_key}/pricings_index", expires_in: 12.hours) do
      @transports = TransportCategory.all.uniq

      mots = tenant.scope['modes_of_transport'].keys.reject do |key|
        !tenant.scope['modes_of_transport'][key]['container'] &&
          !tenant.scope['modes_of_transport'][key]['cargo_item']
      end
      detailed_itineraries = {}
      mot_page_counts = {}
      mots.each do |mot|
        mot_itineraries = @itineraries
                          .where(mode_of_transport: mot)
        detailed_itineraries[mot] = mot_itineraries
                                    .paginate(page: params[mot] || 1)
                                    .map(&:as_pricing_json)

        mot_page_counts[mot] = detailed_itineraries[mot].total_pages
      end
      last_updated = @itineraries.first ? @itineraries.first.updated_at : DateTime.now
      {
        detailedItineraries: detailed_itineraries,
        numItineraryPages:   mot_page_counts,
        transportCategories: @transports,
        lastUpdate:          last_updated
      }
    end
    response_handler(response)
  end

  def client
    @pricings = get_user_pricings(params[:id])
    @client = User.find(params[:id])

    response_handler(userPricings: @pricings, client: @client)
  end

  def search
    query = {
      tenant_id: current_user.tenant_id
    }

    query[:mode_of_transport] = params[:mot] if params[:mot]
    itineraries = Itinerary.where(query).order('name ASC')
    itinerary_results = itineraries.where('name ILIKE ?', "%#{params[:text]}%")
    @transports = TransportCategory.all.uniq
    detailed_itineraries = itinerary_results.paginate(page: params[:page]).map(&:as_pricing_json)
    last_updated = itineraries.first ? itineraries.first.updated_at : DateTime.now
    response_handler(
      detailedItineraries: detailed_itineraries,
      numItineraryPages:   detailed_itineraries.total_pages,
      transportCategories: @transports,
      lastUpdate:          last_updated,
      mode_of_transport:   params[:mot]
    )
  end

  def route
    itinerary = Itinerary.find(params[:id])
    pricings = ordinary_pricings(itinerary)
    user_pricings = user_pricing(itinerary)
    service_levels = itinerary.trips.pluck(:tenant_vehicle_id).uniq.map do |tv_id|
      tenant_vehicle = TenantVehicle.find(tv_id)
      carrier_name = tenant_vehicle.carrier ?
      "#{tenant_vehicle.carrier.name} - #{tenant_vehicle.name}" :
      tenant_vehicle.name
      { label: carrier_name.to_s, value: tenant_vehicle.vehicle_id }
    end
    stops = itinerary.stops.map { |s| { stop: s, hub: s.hub.as_options_json } }
    response_handler(
      itineraryPricingData: pricings,
      itinerary:            itinerary.as_options_json,
      stops:                stops,
      serviceLevels:       service_levels,
      userPricings:         user_pricings
    )
  end

  def assign_dedicated
    new_pricings = params[:clientIds].map do |client_id|
      itinerary_id = params[:pricing][:itinerary_id]
      ex_pricing = Pricing.where(user_id: client_id, itinerary_id: itinerary_id).first
      pricing_to_update = ex_pricing || Pricing.new
      new_pricing_data = params[:pricing].as_json
      new_pricing_data.delete('controller')
      new_pricing_data.delete('subdomain_id')
      new_pricing_data.delete('action')
      new_pricing_data.delete('id')
      new_pricing_data.delete('created_at')
      new_pricing_data.delete('updated_at')
      new_pricing_data.delete('load_type')
      new_pricing_data['user_id'] = client_id.to_i
      pricing_details = new_pricing_data.delete('data')
      pricing_exceptions = new_pricing_data.delete('exceptions')
      pricing_to_update.update(new_pricing_data)
      pricing_details.each do |shipping_type, pricing_detail_data|
        currency = pricing_detail_data.delete('currency')
        pricing_detail_params = pricing_detail_data.merge(
          shipping_type: shipping_type,
          tenant:        current_user.tenant
        )
        range = pricing_detail_params.delete('range')
        pricing_detail = pricing_to_update.pricing_details.find_or_create_by(
          shipping_type: shipping_type,
          tenant:        current_user.tenant
        )
        pricing_detail.update!(pricing_detail_params)
        pricing_detail.update!(range: range, currency_name: currency)
      end

      pricing_exceptions.each do |pricing_exception_data|
        pricing_details = pricing_exception_data.delete('data')
        pricing_exception = pricing_to_update.pricing_exceptions
                                             .where(pricing_exception_data)
                                             .first_or_create(pricing_exception_data.merge(tenant: current_user.tenant))
        pricing_details.each do |shipping_type, pricing_detail_data|
          currency = pricing_detail_data.delete('currency')
          range = pricing_detail_data.delete('range')
          pricing_detail_params = pricing_detail_data
                                  .merge(shipping_type: shipping_type, tenant: current_user.tenant)
          pricing_detail = pricing_exception.pricing_details
                                            .where(pricing_detail_params)
                                            .first_or_create!(pricing_detail_params)
          pricing_detail.update!(range: range, currency_name: currency)
        end
      end

      {
        pricing:            pricing_to_update.as_json,
        transport_category: pricing_to_update.transport_category,
        user_id:            client_id.to_i
      }
    end
    response_handler(new_pricings)
  end

  def update_price
    pricing_to_update = Pricing.find(params[:id])
    new_pricing_data = sanitized_params
    new_pricing_data.delete('cargo_class')
    new_pricing_details = new_pricing_data.delete('data')
    pricing_to_update.update(new_pricing_data)
    update_pricing_details(pricing_to_update)
    update_pricing_exception_data(pricing_to_update)

    response_handler(
      pricing:            pricing_to_update.as_json,
      transport_category: pricing_to_update.transport_category
    )
  end

  def destroy
    pricing_delete(params[:id])
    response_handler({})
  end

  def download_pricings
    options = params[:options].as_json.deep_symbolize_keys!
    options[:tenant_id] = current_user.tenant_id
    url = DocumentService::PricingWriter.new(options).perform
    response_handler(url: url, key: 'pricing')
  end

  def overwrite_main_lcl_carriage
    if params[:file] && params[:file] != 'null'
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::FreightRatesOverwriter.new(
        params:   req,
        _user:    current_user,
        generate: false
      ).perform
      response_handler(results)
    else
      response_handler(false)
    end
  end

  def overwrite_main_fcl_carriage
    if params[:file] && params[:file] != 'null'
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::FreightRatesOverwriter.new(
        params:   req,
        _user:    current_user,
        generate: false
      ).perform
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
        results + itineraries_array(prices, itin)
      end
    end
    results
  end

  def test
    itinerary = Itinerary.find(params[:id])
    itinerary.test_pricings(params[:data], current_user)
  end

  private

  def itineraries_array(prices, itin)
    results = []
    prices.each do |_k, v|
      splits = v.split('_')
      hub1 = splits[0].to_i
      hub2 = splits[1].to_i
      results.push(itin) if itin['first_stop_id'] == hub1 && itin['destination_stop_id'] == hub2
    end
    results
  end

  def ordinary_pricings(itinerary)
    itinerary.pricings.where(user_id: nil).map do |pricing|
      { pricing:            pricing,
        transport_category: pricing.transport_category }
    end
  end

  def user_pricing(itinerary)
    itinerary.pricings.where.not(user_id: nil).map do |pricing|
      { pricing:            pricing,
        transport_category: pricing.transport_category,
        user_id:            pricing.user_id }
    end
  end

  def update_pricing_details(pricing_to_update)
    sanitized_params['data'].each do |shipping_type, pricing_detail_data|
      currency = pricing_detail_data.delete('currency')
      pricing_detail_params = pricing_detail_data.merge(
        shipping_type: shipping_type, tenant: current_user.tenant
      )
      range = pricing_detail_params.delete('range')
      pricing_detail = pricing_to_update.pricing_details.find_or_create_by(
        shipping_type: shipping_type, tenant: current_user.tenant
      )
      pricing_detail.update!(pricing_detail_params)
      pricing_detail.update!(range: range, currency_name: currency)
    end
  end

  def update_pricing_exception_data(pricing_to_update)
    sanitized_params['exceptions']&.each do |pricing_exception_data|
      pricing_details = pricing_exception_data.delete('data')
      pricing_exception = pricing_to_update.pricing_exceptions.where(
        pricing_exception_data
      ).first_or_create(pricing_exception_data.merge(
                          tenant: current_user.tenant
                        ))
      pricing_details.each do |shipping_type, pricing_detail_data|
        currency = pricing_detail_data.delete('currency')
        range = pricing_detail_data.delete('range')
        pricing_detail_params = pricing_detail_data.merge(
          shipping_type: shipping_type, tenant: current_user.tenant
        )
        pricing_detail = pricing_exception.pricing_details.where(
          pricing_detail_params
        ).first_or_create!(pricing_detail_params)
        pricing_detail.update!(range: range, currency_name: currency)
      end
    end
  end

  def sanitized_params
    new_pricing_data = params.as_json
    new_pricing_data.except(
      'controller', 'subdomain_id', 'action', 'id', 'created_at',
      'updated_at', 'load_type', 'currency', 'pricing', 'exceptions'
    )
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
