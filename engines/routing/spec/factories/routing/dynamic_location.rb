
FactoryBot.define do
  factory :dynamic_location, class: 'Routing::Location' do
    lat { 53.558572 }
    lng { 9.9278215 }
    delta { 0.4 }
    locode { nil }
    name { nil }
    country_code { 'de' }
    initialize_with do
      new(
        bounds: FactoryBot.build(:bounds, lat: lat, lng: lng, delta: delta),
        center: FactoryBot.build(:point, lat: lat,lng: lng),
        locode: locode,
        name: name,
        country_code: country_code
      )
    end
  end
end
