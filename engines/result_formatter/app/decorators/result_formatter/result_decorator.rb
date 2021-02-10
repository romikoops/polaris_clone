# frozen_string_literal: true

module ResultFormatter
  class ResultDecorator < ApplicationDecorator
    delegate_all

    delegate :pickup_address, :delivery_address, :client,
      :planned_delivery_date, :planned_pickup_date, :cargo_units, :organization, to: :query

    def valid_until
      @valid_until ||= expiration_date
    end

    def carrier
      @carrier ||= main_freight_section.carrier.upcase
    end

    def service_level
      @service_level ||= main_freight_section.service
    end

    def total
      @total ||= line_items.inject(Money.new(0, currency)) { |sum, item| sum + item.total }
    end

    def transshipment
      @transshipment ||= itinerary.transshipment
    end

    def vessel_name
      @vessel_name ||= ""
    end

    def fees
      @fees ||= ResultFormatter::FeeTableService.new(result: self, scope: scope, type: :pdf).perform
    end

    def currency
      @currency ||= Users::Settings.find_by(user: client)&.currency || scope.dig(:default_currency)
    end

    def voyage_code
      @voyage_code ||= ""
    end

    def imc_reference
      Journey::ImcReference.new(date: created_at).reference
    end

    def has_pre_carriage?
      route_sections_in_order.first.mode_of_transport == "carriage"
    end

    def has_on_carriage?
      route_sections_in_order.last.mode_of_transport == "carriage"
    end

    delegate :mode_of_transport, to: :main_freight_section

    def grand_total_section
      return "" if scope[:hide_grand_total]
      return "" if scope[:hide_converted_grand_total] && currencies.length > 1

      h.render(
        template: "pdf/partials/general/grand_total",
        locals: {total: total.format(rounded_infinite_precision: true, symbol: currency + " ")}
      )
    end

    def currencies
      @currencies ||= line_items.pluck(:total_currency).uniq
    end

    def chargeable_weight_string(section:)
      return "" if ["import", "export"].include?(section)

      target_section = case section
      when "cargo"
        main_freight_section
      when "trucking_pre"
        pre_carriage_section
      else
        on_carriage_section
      end

      cargo_chargeable_weight_string(section: target_section)
    end

    def cargo_chargeable_weight_string(section:)
      row, value = determine_chargeable_weight_row(section: section)
      [
        "<small class='chargeable_weight'>",
        " (Chargeable #{row.capitalize}: ",
        value.round(decimals),
        row == "volume" ? " m<sup>3</sup>" : " kg",
        "</small>"
      ].join
    end

    def determine_chargeable_weight_row(section:)
      Pdf::ChargeableWeightRow.new(
        weight: total_chargeable_weight(section: section).value,
        volume: total_chargeable_volume(section: section).value,
        view_type: scope["chargeable_weight_view"]
      ).perform
    end

    def decimals
      scope.dig("values", "weight", "decimals")
    end

    def transit_time
      @transit_time ||= route_sections.sum(&:transit_time)
    end

    def cargo_items
      @cargo_items ||= cargo_items_for_section(section: main_freight_section)
    end

    def containers
      @containers ||= ResultFormatter::CargoDecorator.decorate_collection(fcl_units, context: decorator_context)
    end

    def aggregated
      @aggregated ||= ResultFormatter::CargoDecorator.decorate_collection(aggr_units, context: decorator_context)
    end

    def query
      @query ||= ResultFormatter::QueryDecorator.decorate(object.query, context: {scope: scope})
    end

    def origin_hub
      @origin_hub ||= Legacy::HubDecorator.decorate(legacy_origin_hub, context: {scope: scope})
    end

    def destination_hub
      @destination_hub ||= Legacy::HubDecorator.decorate(legacy_destination_hub, context: {scope: scope})
    end

    def origin
      @origin ||= origin_hub.name
    end

    def destination
      @destination ||= destination_hub.name
    end

    def origin_free_out
      @origin_free_out ||= origin_hub.free_out
    end

    def destination_free_out
      @destination_free_out ||= destination_hub.free_out
    end

    def decorator_context
      {scope: scope, result: self}
    end

    def import?
      route_sections_in_order.any? do |section|
        section.from == destination_route_point && section.to == destination_route_point
      end
    end

    def export?
      route_sections_in_order.any? do |section|
        section.from == origin_route_point && section.to == origin_route_point
      end
    end

    def customs?
      false # line_items.exists?(customs: true)
    end

    def insurance?
      false # line_items.exists?(insurance: true)
    end

    def addons?
      false
    end

    def notes
      @notes = Notes::Service.new(
        itinerary: itinerary,
        tenant_vehicle: legacy_service,
        remarks: false
      ).fetch.entries
    end

    def pre_carriage_service
      @pre_carriage_service ||= carriage_service_string(carriage: "pre")
    end

    def on_carriage_service
      @on_carriage_service ||= carriage_service_string(carriage: "on")
    end

    def full_pickup_address
      @full_pickup_address ||= pickup_address&.full_address
    end

    def full_delivery_address
      @full_delivery_address ||= delivery_address&.full_address
    end

    def carriage_service_string(carriage:)
      operator = Pdf::CarrierServiceInfo.new(
        result: self, voyage_info: scope[:voyage_info], carriage: carriage
      ).operator
      operator.present? ? "operated by #{operator}" : ""
    end

    def lcl_units
      @lcl_units ||= cargo_units.where(cargo_class: "lcl")
    end

    def fcl_units
      @fcl_units ||= cargo_units.reject(&:lcl?)
    end

    def aggr_units
      @aggr_units ||= cargo_units.where(cargo_class: "aggregated_lcl")
    end

    def exchange_rates
      @exchange_rates ||= ResultFormatter::ExchangeRateService.new(
        base_currency: currency,
        currencies: line_items.pluck(:total_currency).uniq,
        timestamp: object.created_at
      ).perform
    end

    def itinerary
      @itinerary ||= freight_pricing.itinerary || Legacy::Itinerary.new(
        origin_hub: legacy_origin_hub, destination_hub: legacy_destination_hub
      )
    end

    def freight_pricing
      @freight_pricing ||= Pricings::Pricing.find_or_initialize_by(id: metadata_pricing_id)
    end

    def metadatum
      @metadatum ||= Pricings::Metadatum.find_by(result_id: id)
    end

    def metadata_pricing_id
      @metadata_pricing_id ||= begin
        return if metadatum.blank?

        metadatum.breakdowns.where(order: 0).find do |breakdown|
          breakdown.rate_origin["type"] == "Pricings::Pricing"
        end&.rate_origin&.dig("id")
      end
    end

    def legacy_service
      @legacy_service ||= freight_pricing.tenant_vehicle
    end

    def pre_carriage_section
      @pre_carriage_section ||= route_sections_in_order.find { |section|
        section.mode_of_transport == "carriage" && section.to == origin_route_point
      }
    end

    def on_carriage_section
      @on_carriage_section ||= route_sections_in_order.find { |section|
        section.mode_of_transport == "carriage" && section.from == destination_route_point
      }
    end

    def origin_transfer_section
      @origin_transfer_section ||= route_sections_in_order.find { |section|
        section.from == origin_route_point && section.to == origin_route_point
      }
    end

    def destination_transfer_section
      @destination_transfer_section ||= route_sections_in_order.find { |section|
        section.from == destination_route_point && section.to == destination_route_point
      }
    end

    def main_freight_section
      @main_freight_section ||= route_sections_in_order.find { |section|
        section.from != section.to && section.mode_of_transport != "carriage"
      }
    end

    def current_line_item_set
      @current_line_item_set ||= line_item_sets.max_by(&:created_at)
    end

    delegate :line_items, to: :current_line_item_set

    def origin_route_point
      @origin_route_point ||= route_sections_in_order
        .reject { |route_section|
          route_section.mode_of_transport == "carriage" ||
            route_section.order < main_freight_section.order
        }
        .map(&:from)
        .find { |route_point| route_point.locode }
    end

    def destination_route_point
      @destination_route_point ||= route_sections_in_order
        .reject { |route_section|
          route_section.mode_of_transport == "carriage" ||
            route_section.order < main_freight_section.order
        }
        .map(&:to)
        .find { |route_point| route_point.locode }
    end

    def total_chargeable_weight(section:)
      cargo_items_for_section(section: section)
        .inject(Measured::Weight.new(0, "kg")) { |sum, unit| sum + unit.total_weight }
    end

    def total_chargeable_volume(section:)
      cargo_items_for_section(section: section)
        .inject(Measured::Volume.new(0, "m3")) { |sum, unit| sum + unit.total_volume }
    end

    def cargo_items_for_section(section:)
      ResultFormatter::CargoDecorator.decorate_collection(
        lcl_units | aggr_units,
        context: decorator_context.merge(wm_ratio: section.line_items.first.wm_rate)
      )
    end

    def route_sections_in_order
      route_sections.sort_by(&:order)
    end

    def scope
      context.dig(:scope) || {}
    end

    def load_type
      query.load_type == "fcl" ? "container" : "cargo_item"
    end

    def legacy_origin_hub
      @legacy_origin_hub ||= Legacy::Hub.find_by(
        hub_code: origin_route_point.locode,
        hub_type: mode_of_transport,
        organization: organization
      )
    end

    def legacy_destination_hub
      @legacy_destination_hub ||= Legacy::Hub.find_by(
        hub_code: destination_route_point.locode,
        hub_type: mode_of_transport,
        organization: organization
      )
    end
  end
end
