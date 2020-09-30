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

  def origin
    origin_locode || pickup_postal_code || origin_city
  end

  def destination
    destination_locode || delivery_postal_code || destination_city
  end

  def imc_reference
    tenders.pluck(:imc_reference).join("-")
  end

  delegate :total_weight, to: :cargo

  def origin_locode
    origin_nexus&.locode
  end

  def total_weight
    cargo.total_weight.format(".1%<value>f")
  end

  def total_volume
    cargo.total_volume.format(".1%<value>f")
  end

  def origin_city
    pickup_address ? pickup_address.city : origin_nexus.name
  end

  def client_name
    quotation_user_profile.full_name
  end

  def external_id
    quotation_user_profile&.external_id
  end

  def routing
    "#{origin_city} - #{destination_city}"
  end

  def destination_locode
    destination_nexus&.locode
  end

  def destination_city
    delivery_address ? delivery_address.city : destination_nexus.name
  end

  def load_type
    shipment.load_type == "container" ? "FCL" : "LCL"
  end

  def pickup_postal_code
    return unless pickup_address&.zip_code

    "#{pickup_address.country.code}-#{pickup_address.zip_code}"
  end

  def delivery_postal_code
    return unless delivery_address&.zip_code

    "#{delivery_address.country.code}-#{delivery_address.zip_code}"
  end

  def quotation_user_profile
    @quotation_user_profile ||= begin
      profile = Profiles::Profile.find_or_initialize_by(user_id: quotation.user_id)
      Profiles::ProfileDecorator.new(profile)
    end
  end
end
