# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_tender, class: 'Quotations::Tender' do
    carrier_name { 'Sealand' }
    load_type { 'container' }
    amount_cents { 30 }
    amount_currency { 'USD' }
    association :quotation, factory: :quotations_quotation
    association :origin_hub, factory: :legacy_hub
    association :destination_hub, factory: :legacy_hub
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
  end
end
