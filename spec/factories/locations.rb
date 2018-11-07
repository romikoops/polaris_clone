# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    name 'Gothenburg'
    latitude '57.694253'
    longitude '11.854048'
    zip_code '43813'
    geocoded_address '438 80 Landvetter, Sweden'
    city 'Gothenburg'
    association :country
  end
end
