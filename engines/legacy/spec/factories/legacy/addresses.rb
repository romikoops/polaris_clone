# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_address, class: 'Legacy::Address' do
    name { 'Gothenburg' }
    latitude { '57.694253' }
    longitude { '11.854048' }
    zip_code { '43813' }
    geocoded_address { '438 80 Landvetter, Sweden' }
    city { 'Gothenburg' }
    association :country, factory: :legacy_country

    trait :shanghai do
      name { 'Gothenburg' }
      latitude { '57.694253' }
      longitude { '11.854048' }
      zip_code { '20001' }
      geocoded_address { '88 Henan Middle Road, Shanghai' }
      city { 'Shanghai' }
      association :country, factory: :country_china
    end
    factory :shanghai_address, traits: [:shanghai]
  end
end
