# frozen_string_literal: true

module Quotations
  class Creator
    def initialize(schedules:, user:)
      @detailed_schedules = schedules
      @user = user
    end

    def perform
      ActiveRecord::Base.transaction do
        create_quotation
        create_tenders
      end
    end

    private

    def create_quotation
      legacy_tenant_id = @detailed_schedules.first[:meta][:origin_hub].tenant_id
      origin_nexus = @detailed_schedules.first[:meta][:origin_hub].nexus
      destination_nexus = @detailed_schedules.first[:meta][:destination_hub].nexus
      tenant = Tenants::Tenant.find_by(legacy_id: legacy_tenant_id)
      @quotation = Quotation.create(tenant: tenant,
                                    user: @user,
                                    origin_nexus: origin_nexus,
                                    destination_nexus: destination_nexus)
    end

    def create_tenders
      @detailed_schedules.each do |quote_object|
        quote_total = quote_object[:quote][:total]
        meta = quote_object[:meta]
        attributes = meta.slice(*%i(carrier_name load_type tenant_vehicle_id name))
                         .merge(quotation: @quotation,
                                origin_hub: meta[:origin_hub],
                                destination_hub: meta[:destination_hub],
                                amount: quote_total[:value],
                                amount_currency: quote_total[:currency])
        tender = Tender.create(attributes)
        quote_object[:meta][:tender_id] = tender.id
        create_line_items_for_tender(tender, quote_object[:quote])
      end
    end

    def create_line_items_for_tender(tender, quote_object)
      keys = %i(total edited_total name)
      quote_object.except(*keys).values.each do |value|
        value.except(*keys).entries.each do |key, v|
          LineItem.create(charge_category_id: key.to_s.to_i,
                          tender_id: tender.id,
                          amount: v[:total][:value],
                          amount_currency: v[:total][:currency])
        end
      end
    end
  end
end
