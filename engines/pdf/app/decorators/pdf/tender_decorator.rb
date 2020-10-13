# frozen_string_literal: true

module Pdf
  class TenderDecorator < ApplicationDecorator
    delegate_all

    delegate :pickup_address, :delivery_address, :shipment,
      :planned_delivery_date, :planned_pickup_date, to: :quotation
    delegate :start_date, :end_date, :closing_date, to: :trip
    delegate :determine_chargeable_weight_row, to: :cargo

    def valid_until
      @valid_until ||= charge_breakdown.valid_until
    end

    def carrier
      @carrier ||= tenant_vehicle.carrier&.name&.upcase
    end

    def service_level
      @service_level ||= tenant_vehicle.name
    end

    def total
      @total ||= amount.format(symbol: amount.currency.to_s + " ")
    end

    def transshipment
      @transshipment ||= itinerary.transshipment
    end

    def vessel_name
      @vessel_name ||= trip.vessel
    end

    def fees
      @fees ||= ResultFormatter::FeeTableService.new(tender: object, scope: scope, type: :pdf).perform
    end

    def currency
      @currency ||= amount_currency
    end

    def voyage_code
      @voyage_code ||= trip.voyage_code
    end

    def grand_total_section
      return "" if scope[:hide_grand_total]
      return "" if scope[:hide_converted_grand_total] && currencies.length > 1

      h.render(
        template: "pdf/partials/general/grand_total",
        locals: {total: total}
      )
    end

    def currencies
      @currencies ||= line_items.select(:amount_currency)
        .distinct
        .pluck(:amount_currency)
    end

    def chargeable_weight_string(section:)
      return "" if ["import", "export"].include?(section)

      return cargo_chargeable_weight_string if section == "cargo"

      trucking_chargeable_weight(section: section)
    end

    def trucking_chargeable_weight(section:)
      key = section.match?(/pre/) ? "pre_carriage" : "on_carriage"
      [
        "<small class='chargeable_weight'> (Chargeable Weight: ",
        shipment.trucking.dig(key, "chargeable_weight"),
        " kg)</small>"
      ].join
    end

    def cargo_chargeable_weight_string
      row, value = determine_chargeable_weight_row
      [
        "<small class='chargeable_weight'>",
        " (Chargeable #{row.capitalize}: ",
        value.round(decimals),
        row == "volume" ? " m<sup>3</sup>" : " kg",
        "</small>"
      ].join
    end

    def decimals
      scope.dig("values", "weight", "decimals")
    end

    def transit_time
      @transit_time ||= ::Legacy::TransitTime.find_by(
        tenant_vehicle: tenant_vehicle,
        itinerary: itinerary
      )&.duration
    end

    def cargo_items
      @cargo_items ||= Pdf::CargoDecorator.decorate_collection(lcl_units, context: decorator_context)
    end

    def containers
      @containers ||= Pdf::CargoDecorator.decorate_collection(fcl_units, context: decorator_context)
    end

    def aggregated
      @aggregated ||= Pdf::CargoDecorator.decorate_collection(aggr_units, context: decorator_context)
    end

    def cargo
      @cargo ||= Pdf::CargoDecorator.decorate(object.cargo, context: decorator_context)
    end

    def quotation
      @quotation ||= Pdf::QuotationDecorator.decorate(object.quotation, context: {scope: scope})
    end

    def origin_hub
      @origin_hub ||= Legacy::HubDecorator.decorate(object.origin_hub, context: {scope: scope})
    end

    def destination_hub
      @destination_hub ||= Legacy::HubDecorator.decorate(object.destination_hub, context: {scope: scope})
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

    def trip
      @trip ||= charge_breakdown.trip
    end

    def decorator_context
      {scope: scope, tender: object}
    end

    def import?
      line_items.exists?(section: "import_section")
    end

    def export?
      line_items.exists?(section: "export_section")
    end

    def customs?
      line_items.exists?(section: "customs_section")
    end

    def insurance?
      line_items.exists?(section: "insurance_section")
    end

    def addons?
      line_items.exists?(section: "addons_section")
    end

    def notes
      @notes = Notes::Service.new(tender: object, remarks: false).fetch.entries
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
        tender: object, voyage_info: scope[:voyage_info], carriage: carriage
      ).operator
      operator.present? ? "operated by #{operator}" : ""
    end

    def lcl_units
      @lcl_units ||= object.cargo.units.select { |unit| unit.cargo_class_00? && !unit.cargo_type_AGR? }
    end

    def fcl_units
      @fcl_units ||= object.cargo.units.reject(&:cargo_class_00?)
    end

    def aggr_units
      @aggr_units ||= object.cargo.units.select(&:cargo_type_AGR?)
    end

    def exchange_rates
      @exchange_rates ||= ResultFormatter::ExchangeRateService.new(tender: object).perform
    end
  end
end
