# frozen_string_literal: true

namespace :pricings do
  task sync: :environment do
    ::Pricing.find_each do |pricing|
      details = pricing.pricing_details
      new_pricing = ::Pricings::Pricing.find_by(legacy_id: pricing.id)
      new_pricing ||= ::Pricings::Pricing.create!(
        wm_rate: pricing.wm_rate,
        effective_date: pricing.effective_date,
        expiration_date: pricing.expiration_date,
        tenant_id: pricing.tenant_id,
        cargo_class: pricing.transport_category.cargo_class,
        load_type: pricing.transport_category.load_type,
        user_id: pricing.user_id,
        itinerary_id: pricing.itinerary_id,
        tenant_vehicle_id: pricing.tenant_vehicle_id,
        legacy_id: pricing.id
      )
      details.each do |detail|
        next if ::Pricings::Fee.exists?(legacy_id: detail.id)

        rate_basis = ::Pricings::RateBasis.find_by(external_code: detail.rate_basis)
        rate_basis ||= ::Pricings::RateBasis.create!(external_code: detail.rate_basis, internal_code: detail.rate_basis)
        hw_rate_basis = nil
        if detail.hw_rate_basis
          hw_rate_basis = ::Pricings::RateBasis.find_by(external_code: detail.rate_basis)
          hw_rate_basis ||= ::Pricings::RateBasis.create!(external_code: detail.rate_basis, internal_code: detail.rate_basis)
        end
        charge_category = ::Legacy::ChargeCategory.find_by(code: detail.shipping_type, tenant_id: detail.tenant_id)
        charge_category ||= ::Legacy::ChargeCategory.create!(code: detail.shipping_type, tenant_id: detail.tenant_id, name: detail.shipping_type)

        ::Pricings::Fee.create!(
          rate: detail.rate,
          base: 1,
          rate_basis_id: rate_basis.id,
          min: detail.min,
          hw_threshold: detail.hw_threshold,
          hw_rate_basis: hw_rate_basis,
          charge_category_id: charge_category.id,
          range: detail.range,
          currency_name: detail.currency_name,
          currency_id: detail.currency_id,
          pricing_id: new_pricing.id,
          tenant_id: detail.tenant_id,
          legacy_id: detail.id
        )
      end
    end
  end
end

