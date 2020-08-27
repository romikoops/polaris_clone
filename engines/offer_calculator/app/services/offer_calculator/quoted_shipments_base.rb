# frozen_string_literal: true

module OfferCalculator
  class QuotedShipmentsBase
    def initialize(shipment_id:, trip_ids: nil, send_email: false, mailer: nil)
      @shipment = Legacy::Shipment.find(shipment_id)
      @trip_ids = trip_ids
      @send_email = send_email
      @mailer = mailer
    end

    private

    attr_reader :shipment, :send_email, :trip_ids, :mailer

    def clone_shipments
      shipment.charge_breakdowns
        .where(trip_id: target_trip_ids)
        .map { |charge_breakdown| clone_offer(charge_breakdown: charge_breakdown) }
    end

    def clone_offer(charge_breakdown:)
      return if charge_breakdown.destroyed?

      shipment.dup.tap do |cloned_shipment|
        update_cloned_shipment(cloned_shipment: cloned_shipment, charge_breakdown: charge_breakdown)
        clone_cargo(cloned_shipment: cloned_shipment)
        break unless cloned_shipment.valid?

        clone_charge_breakdown(cloned_shipment: cloned_shipment, charge_breakdown: charge_breakdown)
        cloned_shipment.save!
      end
    end

    def clone_cargo(cloned_shipment:)
      if shipment.aggregated_cargo.present?
        cloned_shipment.aggregated_cargo = shipment.aggregated_cargo.dup
        cloned_shipment.aggregated_cargo.set_chargeable_weight!
      end
      cloned_shipment.cargo_units = shipment.cargo_units.map do |unit|
        new_unit = unit.dup
        new_unit.set_chargeable_weight! if cloned_shipment.lcl?
        charge_category_map[unit.id] = new_unit.id
        new_unit
      end
    end

    def clone_charge_breakdown(cloned_shipment:, charge_breakdown:)
      cloned_charge_breakdown = charge_breakdown.dup
      cloned_charge_breakdown.update(shipment: cloned_shipment)
      cloned_charge_breakdown.dup_charges(charge_breakdown: charge_breakdown)
      clone_charges(cloned_charge_breakdown: cloned_charge_breakdown, original: charge_breakdown)
    end

    def clone_pricing_metadatum(clone:, original:)
      metadatum = Pricings::Metadatum.find_by(charge_breakdown_id: original.id)
      return if metadatum.blank?

      clone_metadatum = metadatum.dup.tap do |tapped_metadatum|
        tapped_metadatum.charge_breakdown_id = clone.id
        tapped_metadatum.save
      end

      return unless clone_metadatum.valid?

      metadatum.breakdowns.each do |breakdown|
        breakdown.dup.tap { |clone_breakdown| clone_breakdown.update(metadatum: clone_metadatum) }
      end
      clone_metadatum
    end

    def clone_charges(cloned_charge_breakdown:, original:)
      clone_metadatum = clone_pricing_metadatum(
        clone: cloned_charge_breakdown, original: original
      )
      %w[import export cargo trucking_pre trucking_on].each do |charge_key|
        next if cloned_charge_breakdown.charge(charge_key).nil?

        cloned_charge_breakdown.charge(charge_key).children.each do |new_charge|
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
  end
end
