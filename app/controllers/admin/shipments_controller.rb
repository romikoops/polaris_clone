# frozen_string_literal: true

require "will_paginate/array"

class Admin::ShipmentsController < Admin::AdminBaseController
  def index
    response = Rails.cache.fetch("#{filtered_results.cache_key}/quote_index", expires_in: 12.hours) {
      per_page = params.fetch(:per_page, 4).to_f

      @results = filtered_results.order(updated_at: :desc)
        .paginate(page: params[:quoted_page], per_page: per_page)
      response = {
        quoted: decorate(shipments: @results),
        pages: {
          quoted: params[:quoted_page]
        },
        nexuses: {
          quoted: {
            origin_nexuses: Legacy::Nexus.where(organization: current_organization),
            destination_nexuses: Legacy::Nexus.where(organization: current_organization)
          }
        },
        num_shipment_pages: {
          quoted: @results.total_pages
        }
      }
    }
    response_handler(response)
  end

  def delta_page_handler
    per_page = params.fetch(:per_page, 4).to_f
    shipments = filtered_results.order(updated_at: :desc).paginate(page: params[:page], per_page: per_page)

    response_handler(
      shipments: decorate(shipments: shipments),
      num_shipment_pages: shipments.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  def show
    response = Rails.cache.fetch("#{result.cache_key}/view_shipment", expires_in: 12.hours) {
      {
        shipment: decorated_shipment,
        cargoItems: cargo_items,
        containers: containers,
        aggregatedCargo: aggregated_cargo,
        contacts: [],
        documents: [],
        addresses: addresses,
        cargoItemTypes: cargo_item_types,
        accountHolder: account_holder_format,
        pricingBreakdowns: pricing_breakdowns(result: result)
      }.as_json
    }

    response_handler(response)
  end

  def account_holder_format
    client = query.client
    client.profile.as_json.merge(email: client.email)
  end

  def search_shipments
    results = filtered_results

    per_page = params.fetch(:per_page, 4).to_f
    results = results.sort_by(&:updated_at).paginate(page: params[:page], per_page: per_page)

    response_handler(
      shipments: decorate(shipments: results),
      num_shipment_pages: results.total_pages,
      target: params[:target],
      page: params[:page]
    )
  end

  def upload_client_document
    if params[:file]
      document = Journey::Document.create!(
        query: query,
        kind: params[:type],
        file: params[:file]
      )

      document_with_url = document.as_json.merge(
        signed_url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: "attachment")
      )
    end

    response_handler(document_with_url)
  end

  def update
    @shipment = Shipment.find_by(id: params[:id])
    shipment_action if params[:shipment_action]
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

  private

  def resp_error
    ApplicationError.new(
      http_code: 400,
      code: SecureRandom.uuid,
      message: @shipments.errors.full_messages.join("\n")
    )
  end

  def update_charge_parent(edit_service_charge)
    unless edit_service_charge.parent.nil?
      edit_service_charge.parent.update_edited_price!
      edit_service_charge.parent.save!
    end
  end

  def update_shipment
    if @shipment
      @shipment
    else
      shipment = Shipment.find_by(id: params[:id])
      shipment.total_price = {value: params[:priceObj]["value"], currency: params[:priceObj]["currency"]}
      shipment.save!
      @shipment = shipment
    end
  end

  def decorated_shipment
    Api::V1::ResultDecorator.new(result, context: {scope: current_scope, admin: true}).legacy_address_json
  end

  def addresses
    @addresses ||= {
      origin: {name: query.origin},
      destination: {name: query.destination}
    }
  end

  def options
    @options ||= {
      methods: %i[selected_offer mode_of_transport],
      include: [{destination_nexus: {}},
        {origin_nexus: {}}]
    }
  end

  def populate_contacts
    @shipment_contacts = @shipment.shipment_contacts
    @shipment_contacts.each do |sc|
      next unless sc.contact

      contacts.push(contact: sc.contact,
                    type: sc.contact_type,
                    address: sc.contact.address)
    end
  end

  def hs_codes
    @hs_codes ||= []
  end

  def cargo_item_types
    Legacy::TenantCargoItemType.where(organization: current_organization).each_with_object({}) do |type, types|
      types[type.cargo_item_type_id] = type.cargo_item_type
    end
  end

  def contacts
    @contacts ||= []
  end

  def billable
    params[:billable] || true
  end

  def filtered_results
    @filtered_results ||= begin
      @filtered_results = organization_results
      @filtered_results = @filtered_results.joins(:query).where(journey_queries: { billable: billable })

      if params[:origin_nexus]
        nexus = Legacy::Nexus.find(params[:origin_nexus])
        route_points = Journey::RoutePoint.where(locode: nexus.locode)

        @filtered_results = @filtered_results
          .joins(:route_sections).where(journey_route_sections: {from_id: route_points.ids}).distinct
      end

      if params[:destination_nexus]
        nexus = Legacy::Nexus.find(params[:destination_nexus])
        route_points = Journey::RoutePoint.where(locode: nexus.locode)

        @filtered_results = @filtered_results
          .joins(:route_sections).where(journey_route_sections: {to_id: route_points.ids}).distinct
      end

      if params[:hub_type].present?
        hub_type_array = params[:hub_type].split(",")

        @filtered_results = @filtered_results
          .joins(:route_sections)
          .where(
            journey_route_sections: {mode_of_transport: hub_type_array}
          ).distinct
      end

      if params[:clients]
        @filtered_results = @filtered_results
          .where(journey_queries: {client_id: params[:clients].split(",")})
      end

      if params[:target_user_id]
        @filtered_results = @filtered_results
          .where(journey_queries: {client_id: params[:target_user_id]})
      end

      if params[:query]
        by_client = Users::Client.joins(:profile).where(
          email: params[:query]
        ).or(
          Users::Client.joins(:profile).where(
            users_client_profiles:
            {
              first_name: params[:query]
            }
          )
        ).or(
          Users::Client.joins(:profile).where(
            users_client_profiles:
            {
              last_name: params[:query]
            }
          ).or(
            Users::Client.joins(:profile).where(
              users_client_profiles:
              {
                company_name: params[:query]
              }
            )
          )
        ).select(:id)

        @filtered_results = @filtered_results.where(
          journey_queries: {
            origin: params[:query]
          }
        ).or(
          @filtered_results.where(
            journey_queries: {
              destination: params[:query]
            }
          ).or(
            @filtered_results.where(
              journey_queries: {
                client_id: by_client
              }
            )
          )
        )
      end
      @filtered_results
    end
  end

  def decorate(shipments:)
    shipments.map do |shipment|
      Api::V1::ResultDecorator.decorate(
        shipment,
        context: {scope: current_scope}
      ).legacy_index_json
    end
  end

  def result
    @result ||= Journey::Result.find_by(id: params[:id])
  end

  def cargo_units
    Journey::CargoUnit.where(query: query)
  end

  def cargo_items
    @cargo_items ||= cargo_units.where(cargo_class: "lcl").map { |cargo_item|
      Api::V1::LegacyCargoUnitDecorator.decorate(cargo_item).legacy_format
    }
  end

  def containers
    @containers ||= cargo_units.where.not(cargo_class: ["aggregated_lcl", "lcl"]).map { |container|
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
    @query ||= result.query
  end
end
