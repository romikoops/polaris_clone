# frozen_string_literal: true

module Quotations
  class Creator
    def initialize(charge:, meta:, user:)
      @charge = charge
      @charge_breakdown = charge.charge_breakdown
      @meta = meta
      @user = user
    end

    def perform
      ActiveRecord::Base.transaction do
        find_or_create_quotation
        create_tenders
      end
    end

    private

    def find_or_create_quotation
      legacy_tenant_id = @meta[:origin_hub].tenant_id
      origin_nexus = @meta[:origin_hub].nexus
      destination_nexus = @meta[:destination_hub].nexus
      tenant = Tenants::Tenant.find_by(legacy_id: legacy_tenant_id)
      @quotation = Quotations::Quotation.create(tenant: tenant,
                                    user: @user,
                                    origin_nexus: origin_nexus,
                                    destination_nexus: destination_nexus)
    end

    def create_tenders
      quote_total = charge.price
      attributes = meta.slice(:carrier_name, :load_type, :tenant_vehicle_id, :name)
                       .merge(quotation: @quotation,
                              origin_hub: meta[:origin_hub],
                              destination_hub: meta[:destination_hub],
                              amount: quote_total.value,
                              amount_currency: quote_total.currency)
      tender = Tender.create(attributes)
      charge.charge_breakdown.update(tender_id: tender.id)
      create_line_items_for_tender(tender)
    end

    def create_line_items_for_tender(tender)
      charge_breakdown.charges.where(detail_level: 3).each do |child_charge|
        price = child_charge.price
        LineItem.create(charge_category_id: child_charge.children_charge_category_id,
                        tender_id: tender.id,
                        amount_cents: price.value,
                        amount_currency: price.currency)
      end
    end

    attr_reader :meta, :charge, :charge_breakdown, :user, :quotation
  end
end
