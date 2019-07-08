# frozen_string_literal: true

class Admin::MarginsController < ApplicationController
  def index
    paginated_margins = handle_search(params).paginate(pagination_options)
    response_margins = paginated_margins.map do |margin|
      for_list_json(margin).deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end
    response_handler(
      pagination_options.merge(
        marginData: response_margins,
        numPages: paginated_margins.total_pages
      )
    )
  end

  def destroy
    Pricings::Margin.find(params[:id])&.destroy
    response_handler(true)
  end

  def create # rubocop:disable Metrics/AbcSize
    args = {
      itinerary_ids: params[:itinerary_ids],
      hub_ids: params[:hub_ids],
      cargo_classes: params[:cargo_classes],
      tenant_vehicle_ids: params[:tenant_vehicle_ids],
      pricing_id: params[:pricing_id],
      selectedHubDirection: params[:selectedHubDirection],
      marginType: params[:marginType],
      pricing_id: params[:pricing_id],
      tenant_id: params[:tenant_id],
      groupId: params[:groupId],
      directions: params[:hub_direction],
      operand: params[:operand],
      attached_to: params[:attached_to],
      marginValue: params[:marginValue],
      fineFeeValues: params[:fineFeeValues],
      effective_date: params[:effective_date],
      expiration_date: params[:expiration_date]
    }
    margins = Pricings::MarginCreator.new(args).perform

    response_handler(margins.map { |m| for_list_json(m) })
  end

  def update_multiple # rubocop:disable Metrics/AbcSize
    updated_margins = []
    params[:margins].each do |param_margin|
      margin = Pricings::Margin.find(param_margin[:id])
      margin.update(
        operator: param_margin[:operator],
        value: param_margin[:value],
        effective_date: Date.parse(param_margin[:effectiveDate]).beginning_of_day,
        expiration_date: Date.parse(param_margin[:expirationDate]).end_of_day
      )
      unless param_margin[:margin_details].nil? || param_margin[:margin_details].empty?
        param_margin[:margin_details].each do |param_margin_detail|
          detail = Pricings::Detail.find_by(
            margin: margin,
            charge_category_id: param_margin_detail[:charge_category_id]
          )
          detail.update(operator: param_margin_detail[:operator], value: param_margin_detail[:value])
        end
      end
      updated_margins << for_list_json(margin)
    end
    response_handler(updated_margins)
  end

  def form_data # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    hash = {
      carriers: [],
      service_levels: [],
      cargo_classes: [],
      pricings: []
    }

    if params[:itinerary_id] && !params[:itinerary_id].empty?
      itinerary = Itinerary.find(params[:itinerary_id])

      itinerary.rates.each do |pr|
        unless hash[:cargo_classes].include?(cargo_class: pr.cargo_class, itinerary_id: itinerary.id)
          hash[:cargo_classes].push(cargo_class: pr.cargo_class, itinerary_id: itinerary.id)
        end
        hash[:service_levels].push(
          service_level: pr.tenant_vehicle.full_name,
          itinerary_id: itinerary.id,
          carrier_id: pr.tenant_vehicle.carrier_id,
          tenant_vehicle_id: pr.tenant_vehicle_id,
          cargo_class: pr.cargo_class
        )
        hash[:pricings] << pr.as_json
      end
    else
      hash[:service_levels] = current_tenant.tenant_vehicles.map do |tv|
        {
          service_level: tv.full_name,
          carrier_id: tv.carrier_id,
          tenant_vehicle_id: tv.id
        }
      end
    end
    hash[:groups] = Tenants::Group.where(tenant_id: Tenants::Tenant.find_by(legacy_id: current_tenant.id)&.id)
    response_handler(hash)
  end

  def itinerary_list
    list_options = current_tenant.itineraries.list_search(params[:query]).limit(30).map do |it|
      { label: "(#{it.mode_of_transport.capitalize}) #{it.name}", value: it.as_options_json }
    end
    all = { label: 'All', value: nil }
    response_handler([all, *list_options])
  end

  def test # rubocop:disable Metrics/AbcSize
    target = get_target(type: upload_params[:target_type], id: upload_params[:target_id])
    results = Pricings::Preview.new(target: target, itinerary_id: params[:itinerary_id]).perform
    itinerary = Itinerary.find(params[:itinerary_id])
    tenant_vehicle_options = itinerary.pricings.map { |p| { value: p.tenant_vehicle, label: p.tenant_vehicle.full_name } }
    cargo_class_options = itinerary.pricings.map { |p| { value: p.cargo_class, label: p.cargo_class.humanize } }
    response_handler(
      results: results,
      cargoClasses: cargo_class_options.uniq,
      tenantVehicles: tenant_vehicle_options.uniq
    )
  end

  def fee_data
    result = if params[:margin_type] == 'local_charges'
               local_charge_fees
             elsif params[:margin_type] == 'trucking'
               trucking_fees
             else
               pricing_fees
             end

    response_handler(result)
  end

  def upload
    applicable = get_target(type: upload_params[:target_type], id: upload_params[:target_id])
    case upload_params[:target_type]
    when 'group'
      Tenants::Group.find_by(id: upload_params[:target_id], sandbox: @sandbox)
    when 'company'
      Tenants::Company.find_by(id: upload_params[:target_id], sandbox: @sandbox)
    when 'user'
      Tenants::User.find_by(legacy_id: upload_params[:target_id])
    end
    file = upload_params[:file].tempfile

    options = { tenant: current_tenant,
                file_or_path: file,
                options: { applicable: applicable, sandbox: @sandbox, user: current_user } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def download
    # TODO
  end

  private

  def get_target(type:, id:)
    case type
    when 'group'
      Tenants::Group.find_by(id: id, sandbox: @sandbox)
    when 'company'
      Tenants::Company.find_by(id: id, sandbox: @sandbox)
    when 'user'
      Tenants::User.find_by(legacy_id: id, sandbox: @sandbox)
    end
  end

  def extract_tenant_vehicle_ids
    if params[:tenant_vehicle_ids] == 'all' && params[:itinerary_id]
      current_tenant.itineraries.where(sandbox: @sandbox)
                    .find(params[:itinerary_id]).rates.pluck(:tenant_vehicle_id)
    elsif params[:tenant_vehicle_ids] == 'all'
      current_tenant.tenant_vehicles.where(sandbox: @sandbox).ids
    else
      params[:tenant_vehicle_ids].split(',')
    end
  end

  def extract_cargo_classes
    if params[:cargo_classes] == 'all' && params[:itinerary_id]
      current_tenant.itineraries.where(sandbox: @sandbox)
                    .find(params[:itinerary_id]).rates.pluck(:cargo_class)
    elsif params[:cargo_classes] == 'all'
      %w(lcl) + Legacy::Container::CARGO_CLASSES
    else
      params[:cargo_classes].split(',')
    end
  end

  def pricing_fees # rubocop:disable Metrics/AbcSize
    if params[:pricing_id] && params[:pricing_id] != 'null'
      pricing = current_tenant.rates.where(sandbox: @sandbox).find(params[:pricing_id])
      pricing&.fees&.map(&:fee_name_and_code)
    else
      pricings = current_tenant.rates.where(
        tenant_vehicle_id: extract_tenant_vehicle_ids,
        itinerary_id: params[:itinerary_ids],
        cargo_class: extract_cargo_classes
      )
      pricings.map(&:fees)
              .flatten
              .group_by(&:charge_category_id)
              .values
              .map(&:first)
              .flatten
              .map(&:fee_name_and_code)
    end
  end

  def local_charge_fees
    local_charges =
      current_tenant.local_charges.where(
        sandbox: @sandbox,
        hub_id: params[:hub_ids].split(','),
        direction: params[:directions].split(','),
        counterpart_hub_id: params[:counterpart_hub_id] != 'null' ? params[:counterpart_hub_id] : nil,
        tenant_vehicle_id: extract_tenant_vehicle_ids,
        load_type: extract_cargo_classes
      )
    all_fees = local_charges.pluck(:fees).each_with_object({}) do |fees, hash|
      hash.merge!(fees)
      hash
    end

    all_fees.values.map { |fee| "#{fee['key']} - #{fee['name']}" }
  end

  def trucking_fees
    carriages = params[:directions].map { |dir| dir == 'import' ? 'on' : 'pre' }

    truckings =
      Trucking::Trucking.where(
        sandbox: @sandbox,
        hub_id: params[:hub_ids].split(','),
        carriage: carriages,
        tenant: current_tenant,
        cargo_class: extract_cargo_classes
      )

    truckings.map { |tr| tr&.fees&.values&.map { |fee| "#{fee['key']} - #{fee['name']}" } }.flatten
  end

  def margins
    tenant = ::Tenants::Tenant.find_by(legacy_id: current_tenant.id)
    @margins ||= ::Pricings::Margin.where(tenant_id: tenant.id, sandbox: @sandbox)
  end

  def pagination_options
    {
      page: current_page,
      per_page: (params[:page_size] || params[:per_page])&.to_f
    }.compact
  end

  def current_page
    params[:page]&.to_i || 1
  end

  def handle_search(params) # rubocop:disable Metrics/CyclomaticComplexity
    query = margins
    if params[:target_id]
      case params[:target_type]
      when 'company'
        query = query.where(
          applicable: Tenants::Company.find_by(id: params[:target_id], sandbox: @sandbox)
        )
      when 'group'
        query = query.where(
          applicable: Tenants::Group.find_by(id: params[:target_id], sandbox: @sandbox)
        )
      when 'user'
        query = query.where(
          applicable: Tenants::User.find_by(legacy_id: params[:target_id], sandbox: @sandbox)
        )
      when 'tenant'
        query = query.where(
          applicable: Tenants::Tenant.find_by(legacy_id: params[:target_id])
        )
      when 'itinerary'
        query = query.where(itinerary_id: params[:target_id])
      end
    end
    query = query.search(params[:query]) if params[:query]
    query
  end

  def get_margin_value(operator, value)
    return value.to_d / 100.0 if operator == '%' && value.to_d > 1

    value
  end

  def for_list_json(margin, options = {})
    new_options = options.reverse_merge(
      methods: %i(service_level itinerary_name fee_code cargo_class mode_of_transport)
    )
    margin.as_json(new_options).reverse_merge(
      marginDetails: margin.details.map { |d| detail_list_json(d) }
    ).deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def detail_list_json(detail, options = {})
    new_options = options.reverse_merge(
      methods: %i(rate_basis itinerary_name fee_code)
    )
    detail.as_json(new_options)
  end

  def upload_params
    params.permit(:file, :target_id, :target_type)
  end
end
