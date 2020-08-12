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
      name { 'Shanghai' }
      latitude { '31.232014' }
      longitude { '121.4867159' }
      zip_code { '20001' }
      street { 'Henan Middle Road' }
      street_number { '88' }
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
      street { 'Brooktorkai' }
      street_number { '7' }
      geocoded_address { 'Brooktorkai 7, Hamburg, 20457, Germany' }
      city { 'Hamburg' }
      association :country, factory: :country_de
    end

    trait :dusseldorf do
      name { 'Düsseldorf' }
      city { 'Düsseldorf' }
      street { 'Dorf Street' }
      association :country, factory: :country_de
    end

    factory :hamburg_address, traits: [:hamburg]
    factory :dusseldorf_address, traits: [:dusseldorf]
    factory :shanghai_address, traits: [:shanghai]
    factory :felixstowe_address, traits: [:felixstowe]
    factory :gothenburg_address, traits: [:gothenburg]
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  city             :string
#  geocoded_address :string
#  latitude         :float
#  location_type    :string
#  longitude        :float
#  name             :string
#  photo            :string
#  premise          :string
#  province         :string
#  street           :string
#  street_address   :string
#  street_number    :string
#  zip_code         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  country_id       :integer
#  sandbox_id       :uuid
#
# Indexes
#
#  index_addresses_on_sandbox_id  (sandbox_id)
#
