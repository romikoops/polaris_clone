# frozen_string_literal: true

class ShipmentsController < ApplicationController
  def index
    response = Rails.cache.fetch("#{client_results.cache_key}/shipment_index", expires_in: 12.hours) do
      per_page = params.fetch(:per_page, 4).to_f
      quoted = client_results.order(updated_at: :desc)
        .paginate(page: params[:quoted_page], per_page: per_page)
      num_pages = {
        quoted: quoted.total_pages
      }

      {
        quoted: result_table_list(results: quoted),
        pages: {
          quoted: params[:quoted_page]
        },
        num_shipment_pages: num_pages
      }
    end
    response_handler(response)
  end

  def delta_page_handler
    per_page = params.fetch(:per_page, 4).to_f
    shipments = client_results.order(created_at: :desc).paginate(page: params[:page], per_page: per_page)

    response_handler(
      shipments: result_table_list(results: shipments),
      num_shipment_pages: shipments.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  def new; end

  def search_shipments
    results = client_results.merge(organization_queries.search(params[:query]))
    per_page = params.fetch(:per_page, 4).to_f
    shipments = results.order(:updated_at).paginate(page: params[:page], per_page: per_page)
    response_handler(
      shipments: result_table_list(results: shipments),
      num_shipment_pages: shipments.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  # Uploads document and returns Document item
  def upload_document
    @shipment = Shipment.find_by(id: params[:shipment_id])
    if params[:file]
      document = Legacy::File.create!(
        shipment: @shipment,
        text: params[:file].original_filename.gsub(/[^0-9A-Za-z.\-]/, "_"),
        doc_type: params[:type],
        user: organization_user,
        organization: current_organization,
        file: params[:file]
      )

      document_with_url = document.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: "attachment")
      )
    end

    response_handler(document_with_url)
  end

  def update_user
    Journey::Query.find(update_user_params[:id]).update(client: organization_user, creator: organization_user)
  end

  def show
    response = Rails.cache.fetch("#{result.cache_key}/view_shipment", expires_in: 12.hours) do
      exchange_rates = ResultFormatter::ExchangeRateService.new(
        line_items: decorated_result.line_items
      ).perform

      {
        shipment: decorated_result.legacy_address_json,
        cargoItems: cargo_items.map(&:legacy_format),
        containers: containers.map(&:legacy_format),
        aggregatedCargo: aggregated_cargo,
        contacts: [],
        documents: [],
        addresses: addresses,
        cargoItemTypes: cargo_item_types,
        accountHolder: query.client,
        pricingBreakdowns: pricing_breakdowns(result: result),
        exchange_rates: exchange_rates
      }.as_json
    end

    response_handler(response)
  end

  def filtered_user_results
    @filtered_user_results ||= begin
      @filtered_user_results = client_results
      if params[:origin_nexus]
        nexus = Legacy::Nexus.find(params[:origin_nexus])
        route_points = Journey::RoutePoint.where(locode: nexus.locode)

        @filtered_user_results = @filtered_user_results
          .joins(:route_sections).where(journey_route_sections: { from_id: route_points.ids }).distinct
      end

      if params[:destination_nexus]
        nexus = Legacy::Nexus.find(params[:destination_nexus])
        route_points = Journey::RoutePoint.where(locode: nexus.locode)

        @filtered_user_results = @filtered_user_results
          .joins(:route_sections).where(journey_route_sections: { to_id: route_points.ids }).distinct
      end

      if params[:hub_type] && params[:hub_type] != ""
        hub_type_array = params[:hub_type].split(",")

        @filtered_user_results = @filtered_user_results
          .joins(:route_sections)
          .where(
            journey_route_sections: { mode_of_transport: hub_type_array }
          ).distinct
      end

      @filtered_user_results.distinct
    end
  end

  def update_user_params
    params.permit(:id)
  end

  def decorate(results:)
    results.map do |result|
      Api::V1::ResultDecorator.decorate(
        result,
        context: { scope: current_scope }
      ).legacy_json
    end
  end

  def result
    @result ||= Journey::Result.find(params[:id])
  end

  def cargo_item_types
    cargo_items.each_with_object({}) do |cargo_unit, types|
      cargo_item_type = Legacy::CargoItemType.find(cargo_unit.cargo_item_type_id)
      types[cargo_item_type.id] ||= cargo_item_type.as_json.slice("description", "category", "id")
    end
  end

  def addresses
    @addresses ||= {
      origin: { name: query.origin },
      destination: { name: query.destination }
    }
  end

  def cargo_units
    Journey::CargoUnit.where(query: query)
  end

  def cargo_items
    @cargo_items ||=
      cargo_units.where(cargo_class: "lcl").map do |cargo_item|
        Api::V1::LegacyCargoUnitDecorator.decorate(cargo_item)
      end
  end

  def containers
    @containers ||= cargo_units.where.not(cargo_class: "lcl").map do |container|
      Api::V1::LegacyCargoUnitDecorator.decorate(container)
    end
  end

  def aggregated_cargo
    @aggregated_cargo ||= begin
      agg_units = cargo_units.where(cargo_class: "aggregated_lcl")
      if agg_units.present?
        agg_units.map do |agg|
          Api::V1::LegacyCargoUnitDecorator.decorate(agg).legacy_format
        end
      end
    end
  end

  def query
    @query ||= result.query
  end

  def pricing_breakdowns(result:)
    metadatum = Pricings::Metadatum.find_by(result_id: result.id)
    return [] if metadatum.blank?

    metadatum.breakdowns.map do |breakdown|
      breakdown.as_json
        .merge(
          code: breakdown.code,
          target_name: breakdown.target_name,
          operator: breakdown.source&.operator,
          margin_value: breakdown.source&.value,
          url_id: breakdown.target_id
        )
        .with_indifferent_access
    end
  end

  def decorated_result
    Api::V1::ResultDecorator.new(result, context: { scope: current_scope })
  end

  def result_table_list(results:)
    decorate_results(results: results).map(&:legacy_index_json)
  end

  def client_results
    @client_results ||= Journey::Result.joins(:query).joins(:route_sections)
      .where(
        journey_queries: { status: "completed", client_id: current_user.id, organization_id: current_organization.id }
      )
  end

  def organization_queries
    Api::Query.where(client_id: current_user.id, organization_id: current_organization.id)
  end
end
