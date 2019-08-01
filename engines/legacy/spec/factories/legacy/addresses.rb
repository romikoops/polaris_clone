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
      association :country, factory: :country_cn
    end

    trait :gothenburg do
      name { 'Gothenburg' }
      latitude { '57.694253' }
      longitude { '11.854048' }
      zip_code { '43813' }
      geocoded_address { '438 80 Landvetter, Sweden' }
      city { 'Gothenburg' }
      association :country, factory: :country_se
    end

    trait :felixstowe do
      name { 'Felixstowe' }
      latitude { '51.96' }
      longitude { '1.3277' }
      zip_code { 'IP11 2DX' }
      geocoded_address { '' }
      city { 'Felixstowe' }
      association :country, factory: :country_uk
    end

    trait :hamburg do
      name { 'Hamburg' }
      latitude { '53.55' }
      longitude { '9.927' }
      zip_code { '20457' }
      geocoded_address { '' }
      city { 'Hamburg' }
      association :country, factory: :country_de
    end

    factory :hamburg_address, traits: [:hamburg]
    factory :shanghai_address, traits: [:shanghai]
    factory :felixstowe_address, traits: [:felixstowe]
    factory :gothenburg_address, traits: [:gothenburg]
  end
end
