# frozen_string_literal: true

FactoryBot.define do
  factory :hub do
    trait :with_lat_lng do
      latitude '57.694253'
      longitude '11.854048'
    end

    name 'Gothenburg Port'
    hub_type 'ocean'
    hub_status 'active'
    hub_code 'GOO1'
    association :tenant
    association :address
    association :nexus
    association :mandatory_charge
  end
end
