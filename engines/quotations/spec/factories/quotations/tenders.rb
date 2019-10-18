# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_tender, class: 'Tender' do
    carrier_name { 'Sealand' }
    service_level { 'Standard' }
    load_type { 'container' }
    amount_cents { 30 }
    amount_currency { 'USD' }
    association :quotation, factory: :quotations_quotation
    association :origin_hub, factory: :legacy_hub
    association :destination_hub, factory: :legacy_hub
  end
end
