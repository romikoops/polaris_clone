# frozen_string_literal: true

class ShipmentsController < ApplicationController
  def index
    response = Rails.cache.fetch("#{client_results.cache_key}/shipment_index", expires_in: 12.hours) {
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
    }

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

  def new
  end

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
    Journey::Result.find(update_user_params[:id]).result_set.query.update(client: organization_user)
  end

  def show
    response = Rails.cache.fetch("#{result.cache_key}/view_shipment", expires_in: 12.hours) {
      exchange_rates = ResultFormatter::ExchangeRateService.new(
        base_currency: decorated_result.currency,
        currencies: decorated_result.line_items.pluck(:total_currency).uniq,
        timestamp: result.created_at
      ).perform

      {
        shipment: decorated_result.legacy_address_json,
        cargoItems: cargo_items,
        containers: containers,
        aggregatedCargo: aggregated_cargo,
        contacts: [],
        documents: [],
        addresses: addresses,
        cargoItemTypes: cargo_item_types,
        accountHolder: query.client,
        pricingBreakdowns: pricing_breakdowns(result: result),
        exchange_rates: exchange_rates
      }.as_json
    }

    response_handler(response)
  end

  def filtered_user_results
    @filtered_user_results ||= begin
      @filtered_user_results = client_results
      if params[:origin_nexus]
        nexus = Legacy::Nexus.find(params[:origin_nexus])
        route_points = Journey::RoutePoint.where(locode: nexus.locode)

        @filtered_user_results = @filtered_user_results
          .joins(:route_sections).where(journey_route_sections: {from_id: route_points.ids}).distinct
      end

      if params[:destination_nexus]
        nexus = Legacy::Nexus.find(params[:destination_nexus])
        route_points = Journey::RoutePoint.where(locode: nexus.locode)

        @filtered_user_results = @filtered_user_results
          .joins(:route_sections).where(journey_route_sections: {to_id: route_points.ids}).distinct
      end

      if params[:hub_type] && params[:hub_type] != ""
        hub_type_array = params[:hub_type].split(",")

        @filtered_user_results = @filtered_user_results
          .joins(:route_sections)
          .where(
            journey_route_sections: {mode_of_transport: hub_type_array}
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
        context: {scope: current_scope}
      ).legacy_json
    end
  end

  def result
    @result ||= Journey::Result.find_by(id: params[:id])
  end

  def cargo_item_types
    cargo_units.each_with_object({}) do |cargo_unit, types|
      cargo_unit.commodity_infos.each do |commodity|
        hs_codes << commodity.hs_code
        types[commodity.id] = commodity
      end
    end
  end

  def addresses
    @addresses ||= {
      origin: {name: query.origin},
      destination: {name: query.destination}
    }
  end

  def cargo_units
    Journey::CargoUnit.where(query: query)
  end

  def cargo_items
    @cargo_items ||=
      cargo_units.where(cargo_class: "lcl").map { |cargo_item|
        Api::V1::LegacyCargoUnitDecorator.decorate(cargo_item).legacy_format
      }
  end

  def containers
    @containers ||= cargo_units.where.not(cargo_class: "lcl").map { |container|
      Api::V1::LegacyCargoUnitDecorator.decorate(container).legacy_format
    }
  end

  def aggregated_cargo
    @aggregated_cargo ||= begin
      agg_units = cargo_units.where(cargo_class: "aggregated_lcl")
      return nil if agg_units.empty?

      agg_units.map do |agg|
        Api::V1::LegacyCargoUnitDecorator.decorate(agg).legacy_format
      end
    end
  end

  def query
    @query ||= ::Journey::Query.joins(result_sets: :results)
      .find_by("journey_results.id = ?", result.id)
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
    Api::V1::ResultDecorator.new(result, context: {scope: current_scope})
  end

  def result_table_list(results:)
    decorate_results(results: results).map(&:legacy_index_json)
  end

  def client_results
    @client_results ||= Journey::Result.joins(result_set: :query)
      .where(
        journey_result_sets: {status: "completed"},
        journey_queries: {client_id: current_user.id, organization_id: current_organization.id}
      )
  end

  def organization_queries
    Api::Query.where(client_id: current_user.id, organization_id: current_organization.id)
  end
end
