# frozen_string_literal: true

class Admin::PricingsController < Admin::AdminBaseController # rubocop:disable Metrics/ClassLength, Style/ClassAndModuleChildren
  include ExcelTools
  include PricingTools
  include ItineraryTools

  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    tenant = current_user.tenant
    @itineraries = tenant.itineraries
    response = Rails.cache.fetch("#{@itineraries.cache_key}/pricings_index", expires_in: 12.hours) do
      @transports = TransportCategory.all.uniq
      @scope = ::Tenants::ScopeService.new(user: current_user).fetch
      mots = @scope['modes_of_transport'].keys.reject do |key|
        !@scope['modes_of_transport'][key]['container'] &&
          !@scope['modes_of_transport'][key]['cargo_item']
      end
      detailed_itineraries = {}
      mot_page_counts = {}
      mots.each do |mot|
        mot_itineraries = @itineraries
                          .where(mode_of_transport: mot)
                          .paginate(page: params[mot] || 1)
        detailed_itineraries[mot] = mot_itineraries.map(&:as_pricing_json)
        mot_page_counts[mot] = mot_itineraries.total_pages
      end
      last_updated = @itineraries.first ? @itineraries.first.updated_at : DateTime.now
      {
        detailedItineraries: detailed_itineraries,
        numItineraryPages: mot_page_counts,
        transportCategories: @transports,
        lastUpdate: last_updated
      }
    end
    response_handler(response)
  end

  def client
    @pricings = get_user_pricings(params[:id])
    @client = User.find(params[:id])

    response_handler(userPricings: @pricings, client: @client)
  end

  def search # rubocop:disable Metrics/AbcSize
    query = {
      tenant_id: current_user.tenant_id
    }

    query[:mode_of_transport] = params[:mot] if params[:mot]
    itineraries = Itinerary.where(query).order('name ASC')
    itinerary_results = itineraries.where('name ILIKE ?', "%#{params[:text]}%")
    @transports = TransportCategory.all.uniq
    detailed_itineraries = itinerary_results.paginate(page: params[:page])
    last_updated = itineraries.first ? itineraries.first.updated_at : DateTime.now
    response_handler(
      detailedItineraries: detailed_itineraries.map(&:as_pricing_json),
      numItineraryPages: detailed_itineraries.total_pages,
      transportCategories: @transports,
      lastUpdate: last_updated,
      mode_of_transport: params[:mot]
    )
  end

  def route
    itinerary = Itinerary.find(params[:id])
    pricings = itinerary.pricings
    pricings = pricings.reject { |pricing| pricing&.user&.internal } unless current_user.internal
    response_handler(
      pricings: pricings.map(&:for_table_json),
      itinerary: itinerary,
      stops: itinerary.stops.map(&:as_options_json)
    )
  end

  def assign_dedicated # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    new_pricings = params[:clientIds].map do |client_id| # rubocop:disable Metrics/BlockLength
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
          tenant: current_user.tenant
        )
        range = pricing_detail_params.delete('range')
        pricing_detail = pricing_to_update.pricing_details.find_or_create_by(
          shipping_type: shipping_type,
          tenant: current_user.tenant
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
        pricing: pricing_to_update.as_json,
        transport_category: pricing_to_update.transport_category,
        user_id: client_id.to_i
      }
    end
    response_handler(new_pricings)
  end

  def update_price
    pricing_to_update = Pricing.find(params[:id])
    new_pricing_data = sanitized_params
    new_pricing_data.delete('cargo_class')
    new_pricing_data.delete('data')
    pricing_to_update.update(new_pricing_data)
    update_pricing_details(pricing_to_update)
    update_pricing_exception_data(pricing_to_update)

    response_handler(
      pricing: pricing_to_update.as_json,
      transport_category: pricing_to_update.transport_category
    )
  end

  def destroy
    pricing_delete(params[:id])
    response_handler({})
  end

  def upload
    file = upload_params[:file].tempfile

    options = { tenant: current_tenant,
                file_or_path: file }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def download
    mot = download_params[:mot]
    load_type = download_params[:load_type]
    key = "pricing_#{load_type}"
    new_load_type = load_type_renamed(load_type)
    file_name = "#{current_tenant.subdomain.downcase}__pricing_#{mot.downcase}_#{new_load_type.downcase}"

    options = { tenant: current_tenant,
                specific_identifier: "#{mot}_#{new_load_type}".camelcase,
                file_name: file_name }
    downloader = ExcelDataServices::Loaders::Downloader.new(options)

    document = downloader.perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(key: key, url: rails_blob_url(document.file, disposition: 'attachment'))
  end

  def test
    itinerary = Itinerary.find(params[:id])
    itinerary.test_pricings(params[:data], current_user)
  end

  private

  def load_type_renamed(load_type)
    case load_type
    when 'cargo_item' then 'LCL'
    when 'container' then 'FCL'
    else
      raise StandardError, 'Unknown load type! Expected item of [cargo_item, container].'
    end
  end

  def itineraries_array(prices, itin)
    results = []
    prices.each do |_k, v|
      splits = v.split('_')
      hub_1 = splits[0].to_i
      hub_2 = splits[1].to_i
      results.push(itin) if itin['first_stop_id'] == hub_1 && itin['destination_stop_id'] == hub_2
    end
    results
  end

  def ordinary_pricings(itinerary)
    if current_tenant.quotation_tool?
      itinerary.pricings.map(&:as_json)
    else
      itinerary.pricings.where(user_id: nil).map(&:as_json)
    end
  end

  def user_pricing(itinerary)
    itinerary.pricings.where.not(user_id: nil).map do |pricing|
      { pricing: pricing,
        transport_category: pricing.transport_category,
        user_id: pricing.user_id }
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

  def upload_params
    params.permit(:file, :mot, :load_type)
  end

  def download_params
    params.require(:options).permit(:mot, :load_type)
  end

  def itinerary_pricing_exists?(args)
    Itinerary.find_by(args).nil?
  end
end
