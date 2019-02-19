FactoryBot.define do
  factory :legacy_hub, class: 'Legacy::Hub' do
    trait :with_lat_lng do
      latitude { '57.694253' }
      longitude { '11.854048' }
    end

    name { 'Gothenburg Port' }
    hub_type { 'ocean' }
    hub_status { 'active' }
    hub_code { 'GOO1' }
    association :tenant, factory: :legacy_tenant
    association :address, factory: :legacy_address
    association :nexus, factory: :legacy_nexus

    trait :shanghai do
      name { 'Shanghai Port' }
      hub_type { 'ocean' }
      hub_status { 'active' }
      hub_code { 'SHA1' }
      latitude { '31.2231338' }
      longitude { '120.9162975' }
      association :address, factory: :shanghai_address
    end

    factory :shanghai_hub, traits: [:shanghai]
    # association :mandatory_charge
  end
end
