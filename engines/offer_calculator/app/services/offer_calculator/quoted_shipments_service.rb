# frozen_string_literal: true

module OfferCalculator
  class QuotedShipmentsService < QuotedShipmentsBase
    def perform
      reset_quotation
      clone_shipments
      send_admin_email
      quotation
    end

    private

    def quotation
      @quotation ||= Legacy::Quotation.find_or_create_by(
        user_id: shipment.user_id,
        original_shipment: shipment,
        billing: shipment.billing
      )
    end

    def quotations_quotation
      tender = shipment.charge_breakdowns.first.tender
      Quotations::Quotation.find(tender.quotation_id)
    end

    def reset_quotation
      clear_shipments
      quotation.save unless quotation.new_record?
    end

    def target_trip_ids
      Legacy::Trip.where(id: trip_ids || shipment.charge_breakdowns.select(:trip_id))
        .joins(:itinerary)
        .merge(itineraries)
    end

    def clear_shipments
      if shipment.updated_at < quotation.updated_at
        quotation.shipments.where.not(trip_id: target_trip_ids).destroy_all
      elsif shipment.updated_at > quotation.updated_at
        quotation.shipments.destroy_all
      end
    end

    def itineraries
      query = Legacy::Itinerary.where(organization: shipment.organization)
      if shipment.origin_nexus_id.present?
        query = query.where(origin_hub: Legacy::Hub.where(nexus_id: shipment.origin_nexus_id))
      end
      if shipment.destination_nexus_id.present?
        query = query.where(destination_hub: Legacy::Hub.where(nexus_id: shipment.destination_nexus_id))
      end
      query
    end

    def update_cloned_shipment(cloned_shipment:, charge_breakdown:)
      tender = charge_breakdown.tender
      trip = charge_breakdown.trip
      cloned_shipment.assign_attributes(
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
        desired_start_date: shipment.desired_start_date,
        booking_placed_at: DateTime.now,
        imc_reference: tender.imc_reference
      )
      handle_clone_dates(cloned_shipment: cloned_shipment, trip: trip)
    end

    def handle_clone_dates(cloned_shipment:, trip:)
      if cloned_shipment.has_pre_carriage?
        trucking_seconds = shipment.trucking.dig("pre_carriage", "trucking_time_in_seconds").to_i.seconds
        cloned_shipment.planned_pickup_date = trip.closing_date - 1.day - trucking_seconds
      else
        cloned_shipment.planned_origin_drop_off_date = trip.closing_date - 1.day
      end
    end

    def update_cloned_breakdowns(clone_metadatum:, cargo_unit_id:)
      ::Pricings::Breakdown.where(metadatum: clone_metadatum, cargo_unit_id: cargo_unit_id)
        .update(cargo_unit_id: charge_category_map[cargo_unit_id])
    end

    def charge_category_map
      @charge_category_map ||= {}
    end

    def send_admin_email
      return if mailer.blank? || send_email.blank?

      mailer.constantize.new_quotation_admin_email(quotation: quotations_quotation, shipment: shipment).deliver_later
    end
  end
end
