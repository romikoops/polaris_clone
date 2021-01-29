# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_country, class: "Legacy::Country" do
    name { "United States of America" }
    code { "US" }
    flag { "https://restcountries.eu/data/usa.svg" }

    trait :cn do
      name { "China" }
      code { "CN" }
      flag { "https://restcountries.eu/data/cny.svg" }
    end

    trait :se do
      name { "Sweden" }
      code { "SE" }
      flag { "https://restcountries.eu/data/sek.svg" }
    end

    trait :gb do
      name { "United Kingdom" }
      code { "GB" }
      flag { "https://restcountries.eu/data/gbp.svg" }
    end

    trait :de do
      name { "Germany" }
      code { "DE" }
      flag { "https://restcountries.eu/data/de.svg" }
    end

    trait :nl do
      name { "Netherlands" }
      code { "NL" }
      flag { "https://restcountries.eu/data/nl.svg" }
    end

    factory :country_cn, traits: [:cn]
    factory :country_uk, traits: [:gb]
    factory :country_de, traits: [:de]
    factory :country_se, traits: [:se]
    factory :country_nl, traits: [:nl]
  end
end

def factory_country_from_code(code:)
  existing_country = Legacy::Country.find_by(code: code.upcase)
  return existing_country if existing_country.present?

  if %w[cn gb de se nl].include?(code.downcase)
    FactoryBot.create(:legacy_country, code.downcase.to_sym)
  else
    FactoryBot.create(:legacy_country, code: code.upcase)
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
