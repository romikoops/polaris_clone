# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_addon, class: 'Legacy::Addon' do
    association :tenant, factory: :legacy_tenant
    association :hub, factory: :legacy_hub
    text do
      [
        { 'text' => 'Addon text 1' }
      ]
    end
    read_more { 'Read more...' }
    cargo_class { 'lcl' }
    direction { 'export' }
    addon_type { 'customs_export_paper' }
    fees do
      {
        'ADB' => {
          'key' => 'ADB',
          'name' => 'Customs Export Paper',
          'value' => 75.0,
          'currency' => 'EUR',
          'rate_basis' => 'PER_SHIPMENT'
        }
      }
    end

    trait :unknown_fee do
      fees do
        { 'UNKNOWN_ADB' => { 'unknown' => true } }
      end
    end

    factory :unknown_fee_addon, traits: [:unknown_fee]
  end
end
