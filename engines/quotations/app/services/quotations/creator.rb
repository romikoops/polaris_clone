# frozen_string_literal: true

module Quotations
  class Creator
    def initialize(results:, user:)
      @results = results
      @shipment = results.first[:total].charge_breakdown.shipment
      @origin_nexus = results.dig(0, :schedules, 0).origin_hub.nexus
      @destination_nexus = results.dig(0, :schedules, 0).destination_hub.nexus
      @user = user
    end

    def perform
      ActiveRecord::Base.transaction do
        find_or_create_quotation
        create_tenders
      end
      @quotation
    end

    private

    def find_or_create_quotation
      tenant = Tenants::Tenant.find_by(legacy_id: @shipment.tenant_id)
      @quotation = Quotations::Quotation.create(tenant: tenant,
                                                user: @user,
                                                tenants_user: Tenants::User.find_by(legacy_id: @user.id),
                                                origin_nexus: @origin_nexus,
                                                destination_nexus: @destination_nexus,
                                                pickup_address_id: @shipment.trucking.dig('pre_carriage', 'address_id'),
                                                delivery_address_id: @shipment.trucking
                                                                              .dig('on_carriage', 'address_id'))
    end

    def create_tenders
      results.each do |result|
        tender = Tender.create(tender_attributes_from_result(result: result))
        charge_breakdown = result[:total].charge_breakdown
        charge_breakdown.update(tender_id: tender.id)
        create_line_items_for_tender(tender: tender, charge_breakdown: charge_breakdown)
      end
    end

    def tender_attributes_from_result(result:)
      charge = result[:total]
      schedule = result.dig(:schedules, 0)
      origin_hub = schedule.origin_hub
      destination_hub = schedule.destination_hub
      quote_total = charge.price

      {
        carrier_name: schedule.carrier_name,
        tenant_vehicle_id: schedule.trip.tenant_vehicle_id,
        load_type: shipment.load_type,
        name: schedule.trip.itinerary.name,
        itinerary: schedule.trip.itinerary,
        quotation: quotation,
        origin_hub: origin_hub,
        destination_hub: destination_hub,
        amount: quote_total.value,
        amount_currency: quote_total.currency,
        transshipment: extract_transshipment(result: result)
      }
    end

    def create_line_items_for_tender(tender:, charge_breakdown:)
      charge_breakdown.charges.where(detail_level: 3).each do |child_charge|
        next if child_charge.children_charge_category.code == 'total'

        price = child_charge.price
        line_item_section = "#{child_charge.parent.charge_category.code}_section".to_sym
        LineItem.create(charge_category_id: child_charge.children_charge_category_id,
                        tender_id: tender.id,
                        section: line_item_section,
                        cargo: extract_cargo_from_charge(charge_category: child_charge.charge_category),
                        amount_cents: price.value.to_d * 100,
                        amount_currency: price.currency)
      end
    end

    def extract_cargo_from_charge(charge_category:)
      return if charge_category.cargo_unit_id.nil?

      return shipment.aggregated_cargo if shipment.aggregated_cargo.present?

      shipment.cargo_units.find(charge_category.cargo_unit_id)
    end

    def extract_transshipment(result:)
      result[:pricings_by_cargo_class].values.pluck(:transshipment).first
    end

    attr_reader :meta, :results, :user, :quotation, :shipment
  end
end
