# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_country, class: 'Legacy::Country' do
    name { 'Sweden' }
    code { 'SE' }
    flag { 'https://restcountries.eu/data/swe.svg' }

    trait :cn do
      name { 'China' }
      code { 'CN' }
      flag { 'https://restcountries.eu/data/cny.svg' }
    end

    trait :se do
      name { 'Sweden' }
      code { 'SE' }
      flag { 'https://restcountries.eu/data/sek.svg' }
    end

    trait :uk do
      name { 'United Kingdom' }
      code { 'GB' }
      flag { 'https://restcountries.eu/data/gbp.svg' }
    end

    trait :de do
      name { 'Germany' }
      code { 'DE' }
      flag { 'https://restcountries.eu/data/de.svg' }
    end

    trait :nl do
      name { 'Netherlands' }
      code { 'NL' }
      flag { 'https://restcountries.eu/data/nl.svg' }
    end

    to_create do |instance|
      instance.attributes = Legacy::Country.create_with(code: instance.code)
        .find_or_create_by(
          name: instance.name,
          flag: instance.flag
        )
        .attributes
      instance.reload
    end

    factory :country_cn, traits: [:cn]
    factory :country_uk, traits: [:uk]
    factory :country_de, traits: [:de]
    factory :country_se, traits: [:se]
    factory :country_nl, traits: [:nl]
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string
#  flag       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
