# frozen_string_literal: true

FactoryBot.define do
  factory :pricing do
    wm_rate 'Gothenburg'
    effective_date Date.today
    expiration_date 10.days.from_now
    association :transport_category
    association :tenant
    association :itinerary
    association :tenant_vehicle

    after :create do |pricing|
      create_list :pricing_detail, 1, priceable: pricing, tenant: pricing.tenant
    end
  end
end
