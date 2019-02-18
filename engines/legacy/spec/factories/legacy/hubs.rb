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
    association :tenant, factory: :legacy_address
    association :address, factory: :legacy_address
    association :nexus, factory: :legacy_nexus
    # association :mandatory_charge
  end
end
