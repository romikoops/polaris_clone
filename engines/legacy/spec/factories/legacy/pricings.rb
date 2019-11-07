FactoryBot.define do
  factory :legacy_pricing, class: 'Legacy::Pricing' do
    wm_rate { 'Gothenburg' }
    effective_date { Date.today }
    expiration_date { 10.days.from_now }
    association :transport_category, factory: :transport_category
    association :tenant, factory: :legacy_tenant
    association :itinerary, factory: :legacy_itinerary
    association :tenant_vehicle, factory: :legacy_tenant_vehicle

    transient do
      pricing_detail_attrs { {} }
    end

    after :create do |pricing, evaluator|
      pricing_detail_options = { priceable: pricing, tenant: pricing.tenant }
      pricing_detail_options.merge!(evaluator.pricing_detail_attrs)
      create_list :legacy_pricing_detail, 1, **pricing_detail_options
    end
  end
end
