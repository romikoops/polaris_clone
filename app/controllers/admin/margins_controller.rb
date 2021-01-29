# frozen_string_literal: true

class Admin::MarginsController < Admin::AdminBaseController
  def index
    paginated_margins = handle_search(params).paginate(pagination_options)
    response_margins = paginated_margins.map { |margin|
      for_list_json(margin).deep_transform_keys { |key| key.to_s.camelize(:lower) }
    }
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

  def create
    margins = Pricings::MarginCreator.new(create_params.to_h.deep_symbolize_keys).perform

    response_handler(margins.map { |m| for_list_json(m) })
  end

  def update_multiple
    updated_margins = []
    params[:margins].each do |param_margin|
      margin = Pricings::Margin.find(param_margin[:id])
      margin.update(
        operator: param_margin[:operator],
        value: param_margin[:value],
        effective_date: Date.parse(param_margin[:effectiveDate]).beginning_of_day,
        expiration_date: Date.parse(param_margin[:expirationDate]).end_of_day
      )
      if param_margin[:margin_details].present?
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

  def form_data
    hash = {
      carriers: [],
      service_levels: [],
      cargo_classes: [],
      pricings: []
    }

    if params[:itinerary_id].present?
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
      hash[:service_levels] = Legacy::TenantVehicle.where(organization_id: current_organization.id).map { |tv|
        {
          service_level: tv.full_name,
          carrier_id: tv.carrier_id,
          tenant_vehicle_id: tv.id
        }
      }
    end
    hash[:groups] = Groups::Group.where(organization_id: current_organization.id)
    response_handler(hash)
  end

  def itinerary_list
    list_options = Legacy::Itinerary
      .where(organization: current_organization)
      .list_search(params[:query]).limit(30).map { |it|
      {label: "(#{it.mode_of_transport.capitalize}) #{it.name}", value: it.as_options_json}
    }
    all = {label: "All", value: nil}
    response_handler([all, *list_options])
  end

  def test
    results = Pricings::Preview.new(
      target: get_target(type: test_params[:targetType], id: test_params[:targetId]),
      params: test_params,
      organization: current_organization
    ).perform
    response_handler(results: results)
  end

  def fee_data
    result = if params[:margin_type] == "local_charges"
      local_charge_fees
    elsif params[:margin_type] == "trucking"
      trucking_fees
    else
      pricing_fees
    end

    response_handler(result)
  end

  def upload
    applicable = get_target(type: upload_params[:target_type], id: upload_params[:target_id])
    handle_upload(
      params: upload_params,
      text: "target_id:#{upload_params[:target_id]},target_type:#{upload_params[:target_type]}",
      type: "margins",
      options: {
        applicable: applicable,
        group_id: upload_params[:group_id],
        user: organization_user
      }
    )
  end

  def download
    # TODO
  end

  private

  def get_target(type:, id:)
    case type
    when "group"
      Groups::Group.find_by(id: id)
    when "company"
      Companies::Company.find_by(id: id)
    when "user"
      Users::Client.find_by(id: id)
    end
  end

  def extract_tenant_vehicle_ids
    if params[:tenant_vehicle_ids] == "all" && params[:itinerary_id]
      Legacy::Itinerary
        .find_by(id: params[:itinerary_id], organization: current_organization)
        .rates.pluck(:tenant_vehicle_id)
    elsif params[:tenant_vehicle_ids] == "all"
      Legacy::TenantVehicle.where(organization: current_organization).ids
    else
      params[:tenant_vehicle_ids].split(",")
    end
  end

  def extract_cargo_classes
    if params[:cargo_classes] == "all" && params[:itinerary_id]
      Legacy::Itinerary.where(organization: current_organization)
        .find(params[:itinerary_id]).rates.pluck(:cargo_class)
    elsif params[:cargo_classes] == "all"
      %w[lcl] + Legacy::Container::CARGO_CLASSES
    else
      params[:cargo_classes].split(",")
    end
  end

  def pricing_fees
    if params[:pricing_id] && params[:pricing_id] != "null"
      pricing = Pricings::Pricing.find_by(organization: current_organization, id: params[:pricing_id])
      pricing&.fees&.map(&:fee_name_and_code)
    else
      pricings = Pricings::Pricing.where(
        organization: current_organization,
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
      Legacy::LocalCharge.where(
        organization: current_organization,
        hub_id: params[:hub_ids].split(","),
        direction: params[:directions].split(","),
        counterpart_hub_id: params[:counterpart_hub_id] != "null" ? params[:counterpart_hub_id] : nil,
        tenant_vehicle_id: extract_tenant_vehicle_ids,
        load_type: extract_cargo_classes
      )
    all_fees = local_charges.pluck(:fees).each_with_object({}) { |fees, hash|
      hash.merge!(fees)
      hash
    }

    all_fees.values.map { |fee| "#{fee["key"]} - #{fee["name"]}" }
  end

  def trucking_fees
    carriages = params[:directions].map { |dir| dir == "import" ? "on" : "pre" }

    truckings =
      Trucking::Trucking.where(
        hub_id: params[:hub_ids].split(","),
        carriage: carriages,
        organization: current_organization,
        cargo_class: extract_cargo_classes
      )

    truckings.map { |tr| tr&.fees&.values&.map { |fee| "#{fee["key"]} - #{fee["name"]}" } }.flatten
  end

  def margins
    @margins ||= ::Pricings::Margin.where(organization_id: current_organization.id)
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

  def handle_search(params)
    query = margins
    if params[:target_id]
      case params[:target_type]
      when "company"
        query = query.where(
          applicable: Companies::Company.find_by(id: params[:target_id])
        )
      when "group"
        query = query.where(
          applicable: Groups::Group.find_by(id: params[:target_id])
        )
      when "user"
        query = query.where(
          applicable: Users::Client.find_by(id: params[:target_id])
        )
      when "tenant"
        query = query.where(
          applicable: Organizations::Organization.find_by(id: params[:target_id])
        )
      when "itinerary"
        query = query.where(itinerary_id: params[:target_id])
      end
    end
    query = query.search(params[:query]) if params[:query]
    query
  end

  def get_margin_value(operator, value)
    return value.to_d / 100.0 if operator == "%" && value.to_d > 1

    value
  end

  def for_list_json(margin, options = {})
    new_options = options.reverse_merge(
      methods: %i[service_level itinerary_name fee_code cargo_class mode_of_transport]
    )
    margin.as_json(new_options).reverse_merge(
      marginDetails: margin.details.map { |d| detail_list_json(d) }
    ).deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def detail_list_json(detail, options = {})
    new_options = options.reverse_merge(
      methods: %i[rate_basis itinerary_name fee_code]
    )
    detail.as_json(new_options)
  end

  def upload_params
    params.permit(:async, :file, :target_id, :target_type)
  end

  def test_params
    params.permit(
      :selectedOriginHub,
      :selectedDestinationHub,
      :targetType,
      :targetId,
      :margin,
      :selectedCargoClass,
      selectedOriginTrucking: %i[lat lng],
      selectedDestinationTrucking: %i[lat lng]
    )
  end

  def create_params
    params.permit(
      :pricing_id,
      :selectedHubDirection,
      :marginType,
      :organization_id,
      :groupId,
      :attached_to,
      :marginValue,
      :effective_date,
      :expiration_date,
      operand: {},
      counterpart_hub: {},
      directions: [],
      cargo_classes: [],
      hub_ids: [],
      fineFeeValues: {},
      hub_direction: [],
      itinerary_ids: [],
      tenant_vehicle_ids: []
    )
  end
end
