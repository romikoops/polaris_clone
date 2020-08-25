# frozen_string_literal: true

class QuotationDecorator < Draper::Decorator
  decorates "Quotations::Quotation"
  delegate_all

  decorates_association :user, with: Api::V1::UserDecorator
  decorates_association :origin_nexus, with: Api::V1::NexusDecorator
  decorates_association :destination_nexus, with: Api::V1::NexusDecorator

  def shipment
    Legacy::Shipment.with_deleted.find(object.legacy_shipment_id)
  end

  def legacy_json
    {
      quotationId: id,
      completed: completed,
      shipment: shipment,
      results: results,
      originHubs: tenders.map(&:origin_hub),
      destinationHubs: tenders.map(&:destination_hub),
      cargoUnits: cargo_units,
      aggregatedCargo: shipment.aggregated_cargo
    }
  end

  def results
    object.tenders.map do |tender|
      OfferCalculator::Service::OfferCreators::LegacyResponse.response(
        offer: nil,
        charge_breakdown: tender.charge_breakdown,
        meta: legacy_meta(tender: tender),
        scope: scope
      )
    end
  end

  def legacy_meta(tender:)
    OfferCalculator::Service::OfferCreators::LegacyMeta.meta(
      offer: nil, shipment: shipment, tender: tender, scope: scope
    )
  end

  def scope
    context.dig(:scope) || {}
  end

  def cargo_units
    if shipment.lcl? && !shipment.aggregated_cargo
      shipment.cargo_units.map(&:with_cargo_type)
    elsif shipment.lcl? && shipment.aggregated_cargo
      [shipment.aggregated_cargo]
    else
      shipment.cargo_units
    end
  end
end
