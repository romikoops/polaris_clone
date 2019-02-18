FactoryBot.define do
  factory :legacy_address, class: 'Legacy::Address' do
    name { 'Gothenburg' }
    latitude { '57.694253' }
    longitude { '11.854048' }
    zip_code { '43813' }
    geocoded_address { '438 80 Landvetter, Sweden' }
    city { 'Gothenburg' }
    association :country, factory: :legacy_country
  end
end
