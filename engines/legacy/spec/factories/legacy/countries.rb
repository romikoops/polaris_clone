# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_country, class: 'Legacy::Country' do
    name { 'Sweden' }
    code { 'SE' }
    flag { 'https://restcountries.eu/data/swe.svg' }

    trait :china do
      name { 'China' }
      code { 'CN' }
      flag { 'https://restcountries.eu/data/cny.svg' }
    end

    factory :country_china, traits: [:china]
  end
end
