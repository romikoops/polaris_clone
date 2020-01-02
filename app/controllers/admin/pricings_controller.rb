# frozen_string_literal: true

class Admin::PricingsController < Admin::AdminBaseController # rubocop:disable Metrics/ClassLength, Style/ClassAndModuleChildren
  include ExcelTools
  include ItineraryTools

  def index
    paginated_pricing_itineraries = handle_search.paginate(pagination_options)
    response_pricing_itineraries = paginated_pricing_itineraries.map do |itinerary|
      for_table_json(itinerary).deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    response_handler(
      pagination_options.merge(
        pricingData: response_pricing_itineraries,
        numPages: paginated_pricing_itineraries.total_pages
      )
    )
  end

  def client
    @client = User.find_by(id: params[:id], sandbox: @sandbox)
    @pricings = PricingTools.new(user: @client).get_user_pricings(params[:id])

    response_handler(userPricings: @pricings, client: @client)
  end

  def search # rubocop:disable Metrics/AbcSize
    query = {
      tenant_id: current_user.tenant_id,
      sandbox: @sandbox
    }

    query[:mode_of_transport] = params[:mot] if params[:mot]
    itineraries = Itinerary.where(query).order('name ASC')
    itinerary_results = itineraries.where('name ILIKE ?', "%#{params[:text]}%")
    @transports = TransportCategory.all.where(sandbox: @sandbox).uniq
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

  def disable
    pricing = Pricings::Pricing.find_by(
      id: params[:pricing_id],
      tenant_id: params[:tenant_id],
      sandbox: @sandbox
    )
    pricing.update(internal: params[:action] == 'disable')

    response_handler(pricing.for_table_json)
  end

  def route
    itinerary = Itinerary.find_by(id: params[:id], sandbox: @sandbox)

    pricings = pricings_based_on_scope(itinerary)
    unless current_user.internal
      # Filter out all pricings that have a user with `internal == true`, but keep the ones that don't have a user
      pricings = pricings.left_outer_joins(:user)
                         .where(users: { internal: [nil, false] })
    end

    response_handler(
      pricings: pricings.map(&:for_table_json),
      itinerary: itinerary,
      stops: itinerary.stops.map(&:as_options_json)
    )
  end

  def group
    pricings = Pricings::Pricing.where(sandbox: @sandbox, group_id: params[:id])

    response_handler(
      pricings: pricings.map(&:for_table_json),
      group_id: params[:id]
    )
  end

  def assign_dedicated # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    new_pricings = params[:clientIds].map do |client_id| # rubocop:disable Metrics/BlockLength
      itinerary_id = params[:pricing][:itinerary_id]
      ex_pricing = Pricing.where(user_id: client_id, itinerary_id: itinerary_id, sandbox: @sandbox).first
      pricing_to_update = ex_pricing || Pricing.new

      new_pricing_data = params[:pricing].as_json
      new_pricing_data.except!(
        'action',
        'controller',
        'created_at',
        'id',
        'load_type',
        'subdomain_id',
        'updated_at'
      )
      pricing_details = new_pricing_data.delete('data')
      pricing_exceptions = new_pricing_data.delete('exceptions')
      new_pricing_data['user_id'] = client_id.to_i
      pricing_to_update.update(new_pricing_data)

      pricing_details.each do |shipping_type, pricing_detail_data|
        currency = pricing_detail_data.delete('currency')
        pricing_detail_params = pricing_detail_data.merge(
          shipping_type: shipping_type,
          tenant: current_tenant
        )
        range = pricing_detail_params.delete('range')
        pricing_detail = pricing_to_update.pricing_details.find_or_create_by(
          shipping_type: shipping_type,
          tenant: current_tenant,
          sandbox: @sandbox
        )
        pricing_detail.update!(pricing_detail_params)
        pricing_detail.update!(range: range, currency_name: currency)
      end

      pricing_exceptions.each do |pricing_exception_data|
        pricing_details = pricing_exception_data.delete('data')
        pricing_exception = pricing_to_update
                            .pricing_exceptions
                            .where(pricing_exception_data)
                            .first_or_create(pricing_exception_data.merge(tenant: current_tenant))

        pricing_details.each do |shipping_type, pricing_detail_data|
          currency = pricing_detail_data.delete('currency')
          range = pricing_detail_data.delete('range')
          pricing_detail_params = pricing_detail_data.merge(shipping_type: shipping_type,
                                                            tenant: current_tenant)
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
    pricing_to_update = Pricing.find_by(id: params[:id], sandbox: @sandbox)
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
    association = current_scope[:base_pricing] ? Pricings::Pricing : Legacy::Pricing
    association.find_by(
      tenant_id: current_tenant.id,
      id: params[:id],
      sandbox: @sandbox
    )&.destroy

    response_handler({})
  end

  def upload
    document = Document.create!(
      text: "group_id:#{upload_params[:group_id] || 'all'}",
      doc_type: 'pricings',
      sandbox: @sandbox,
      tenant: current_tenant,
      file: upload_params[:file]
    )

    file = upload_params[:file].tempfile
    options = { tenant: current_tenant,
                file_or_path: file,
                options: {
                  sandbox: @sandbox,
                  user: current_user,
                  group_id: upload_params[:group_id],
                  document: document
                } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    response_handler(uploader.perform)
  end

  def download
    mot = download_params[:mot]
    load_type = download_params[:load_type]
    group_id = download_params[:group_id]
    key = 'pricings'
    new_load_type = load_type_renamed(load_type)
    file_name = "#{::Tenants::Tenant.find_by(legacy_id: current_tenant.id).slug}__pricing_#{mot.downcase}_#{new_load_type.downcase}"

    options = { tenant: current_tenant,
                specific_identifier: "#{mot}_#{new_load_type}".camelcase,
                file_name: file_name,
                sandbox: @sandbox,
                group_id: group_id }
    downloader = ExcelDataServices::Loaders::Downloader.new(options)
    document = downloader.perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(key: key, url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment'))
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

  def update_pricing_details(pricing_to_update)
    sanitized_params['data'].each do |shipping_type, pricing_detail_data|
      currency = pricing_detail_data.delete('currency')
      pricing_detail_params = pricing_detail_data.merge(
        shipping_type: shipping_type, tenant: current_tenant
      )

      range = pricing_detail_params.delete('range')
      pricing_detail = pricing_to_update.pricing_details.find_or_create_by(
        shipping_type: shipping_type, tenant: current_tenant
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
      ).first_or_create(pricing_exception_data.merge(tenant: current_tenant))

      pricing_details.each do |shipping_type, pricing_detail_data|
        currency = pricing_detail_data.delete('currency')
        range = pricing_detail_data.delete('range')

        pricing_detail_params = pricing_detail_data.merge(
          shipping_type: shipping_type, tenant: current_tenant
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
    params.permit(:file, :mot, :load_type, :group_id)
  end

  def download_params
    params.require(:options).permit(:mot, :load_type, :group_id)
  end

  def itinerary_pricing_exists?(args)
    Itinerary.find_by(args).nil?
  end

  def handle_search
    itinerary_relation = ::Legacy::Itinerary.where(tenant_id: current_tenant.id, sandbox: @sandbox)

    relation_modifiers = {
      name: ->(query, param) { query.list_search(param) },
      name_desc: ->(query, param) { query.ordered_by(:name, param) },
      mot: ->(query, param) { param == 'all' ? query : query.where(mode_of_transport: param) },
      mot_desc: ->(query, param) { query.ordered_by(:mode_of_transport, param) }
    }

    relation_modifiers.each do |key, lambd|
      itinerary_relation = lambd.call(itinerary_relation, search_params[key]) if search_params[key]
    end

    itinerary_relation
  end

  def pagination_options
    {
      page: current_page,
      per_page: (params[:page_size] || params[:per_page])&.to_f
    }.compact
  end

  def for_table_json(itinerary)
    itinerary.as_json(methods: [:pricing_count]).merge('last_expiry' => last_expiry(itinerary))
  end

  def last_expiry(itinerary)
    pricings_based_on_scope(itinerary)
      .where('expiration_date > ?', DateTime.now)
      .order(:expiration_date)
      .first&.expiration_date
  end

  def current_page
    params[:page]&.to_i || 1
  end

  def search_params
    params.permit(
      :mot,
      :mot_desc,
      :last_expiry_desc,
      :name,
      :name_desc,
      :page_size,
      :per_page
    )
  end

  def pricings_based_on_scope(itinerary)
    pricings = current_scope['base_pricing'] ? itinerary.rates : itinerary.pricings
    pricings.where(sandbox: @sandbox)
  end
end
