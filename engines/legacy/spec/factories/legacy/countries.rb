FactoryBot.define do
  factory :legacy_country, class: 'Legacy::Country' do
    name { 'Sweden' }
    code { 'SE' }
    flag { 'https://restcountries.eu/data/swe.svg' }
  end
end
