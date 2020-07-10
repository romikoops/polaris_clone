# frozen_string_literal: true

class QuotedShipmentsService
  def initialize(shipment:, trip_ids: nil, send_email: false)
    @shipment = shipment
    @trip_ids = trip_ids
    @send_email = send_email
  end

  def perform
    reset_quotation
    clone_shipments
    send_admin_email if send_email
    quotation
  end

  private

  attr_reader :shipment, :send_email, :trip_ids

  def quotation
    @quotation ||= Legacy::Quotation.find_or_create_by(
      user_id: shipment.user_id,
      original_shipment: shipment,
      billing: shipment.billing
    )
  end

  def reset_quotation
    if quotation && shipment.updated_at < quotation.updated_at
      clear_past_shipments
    elsif quotation && shipment.updated_at > quotation.updated_at
      clear_all_shipments
    end
    quotation.touch unless quotation.new_record?
  end

  def target_trip_ids
    trip_ids || shipment.charge_breakdowns.select(:trip_id)
  end

  def clear_past_shipments
    quotation.shipments.where.not(trip_id: target_trip_ids).destroy_all
  end

  def clear_all_shipments
    quotation.shipments.destroy_all
  end

  def clone_shipments
    shipment.charge_breakdowns.map { |charge_breakdown| clone_offer(charge_breakdown: charge_breakdown) }
  end

  def clone_offer(charge_breakdown:)
    shipment.dup.tap do |clone_shipment|
      clone_cargo(clone_shipment: clone_shipment)
      update_cloned_shipment(clone_shipment: clone_shipment, charge_breakdown: charge_breakdown)
      clone_charge_breakdown(clone_shipment: clone_shipment, charge_breakdown: charge_breakdown)
      clone_shipment.save!
    end
  end

  def update_cloned_shipment(clone_shipment:, charge_breakdown:)
    tender = charge_breakdown.tender
    trip = charge_breakdown.trip
    clone_shipment.assign_attributes(
      status: "quoted",
      origin_hub: tender.origin_hub,
      destination_hub: tender.destination_hub,
      origin_nexus_id: tender.origin_hub.nexus_id,
      destination_nexus_id: tender.destination_hub.nexus_id,
      trip_id: charge_breakdown.trip_id,
      planned_eta: trip.end_date,
      planned_etd: trip.start_date,
      tender_id: tender.id,
      quotation_id: quotation.id,
      itinerary_id: trip.itinerary_id,
      desired_start_date: shipment.desired_start_date
    )
    handle_clone_dates(clone_shipment: clone_shipment, trip: trip)
  end

  def clone_cargo(clone_shipment:)
    if shipment.aggregated_cargo.present?
      clone_shipment.aggregated_cargo = shipment.aggregated_cargo.dup
      clone_shipment.aggregated_cargo.set_chargeable_weight!
    end
    clone_shipment.cargo_units = shipment.cargo_units.map do |unit|
      new_unit = unit.dup
      new_unit.set_chargeable_weight! if clone_shipment.lcl?
      charge_category_map[unit.id] = new_unit.id
      new_unit
    end
  end

  def handle_clone_dates(clone_shipment:, trip:)
    if clone_shipment.has_pre_carriage?
      trucking_seconds = shipment.trucking.dig("pre_carriage", "trucking_time_in_seconds").to_i.seconds
      clone_shipment.planned_pickup_date = trip.closing_date - 1.day - trucking_seconds
    else
      clone_shipment.planned_origin_drop_off_date = trip.closing_date - 1.day
    end
  end

  def clone_charge_breakdown(clone_shipment:, charge_breakdown:)
    clone_charge_breakdown = charge_breakdown.dup
    clone_charge_breakdown.update(shipment: clone_shipment)
    clone_charge_breakdown.dup_charges(charge_breakdown: charge_breakdown)
    clone_charges(clone_charge_breakdown: clone_charge_breakdown, original: charge_breakdown)
  end

  def clone_pricing_metadatum(clone:, original:)
    metadatum = Pricings::Metadatum.find_by(charge_breakdown_id: original.id)
    return if metadatum.blank?

    clone_metadatum = metadatum.dup.tap do |metadatum|
      metadatum.charge_breakdown_id = clone.id
      metadatum.save
    end

    metadatum.breakdowns.each do |breakdown|
      breakdown.dup.tap { |clone_breakdown| clone_breakdown.update(metadatum: clone_metadatum) }
    end
    clone_metadatum
  end

  def clone_charges(clone_charge_breakdown:, original:)
    clone_metadatum = clone_pricing_metadatum(
      clone: clone_charge_breakdown, original: original
    )
    %w[import export cargo trucking_pre trucking_on].each do |charge_key|
      next if clone_charge_breakdown.charge(charge_key).nil?

      clone_charge_breakdown.charge(charge_key).children.each do |new_charge|
        old_charge_category = new_charge&.children_charge_category
        next if old_charge_category.nil?

        new_charge_category = clone_charge_category(original: old_charge_category)
        if clone_metadatum
          update_cloned_breakdowns(clone_metadatum: clone_metadatum, cargo_unit_id: old_charge_category.cargo_unit_id)
        end
        new_charge.children_charge_category = new_charge_category
        new_charge.save!
      end
    end
  end

  def clone_charge_category(original:)
    Legacy::ChargeCategory.find_or_create_by(
      code: original.code,
      name: original.name,
      organization_id: original.organization_id,
      cargo_unit_id: charge_category_map[original.cargo_unit_id]
    )
  end

  def update_cloned_breakdowns(clone_metadatum:, cargo_unit_id:)
    Pricings::Breakdown.where(metadatum: clone_metadatum, cargo_unit_id: cargo_unit_id)
      .update_all(cargo_unit_id: charge_category_map[cargo_unit_id])
  end

  def charge_category_map
    @charge_category_map ||= {}
  end

  def send_admin_email
    QuoteMailer.quotation_admin_email(quotation, shipment).deliver_later
  end
end
