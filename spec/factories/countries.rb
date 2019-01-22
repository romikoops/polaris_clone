# frozen_string_literal: true

COUNTRIES = [
  { name: 'Sweden', code: 'SE', flag: 'https://restcountries.eu/data/swe.svg' },
  { name: 'China', code: 'CN', flag: 'https://restcountries.eu/data/chn.svg' },
  { name: 'Germany', code: 'DE', flag: 'https://restcountries.eu/data/deu.svg' }
].freeze
FactoryBot.define do
  factory :country do
    trait :with_sequence do
      %i(name code flag).each do |attribute|
        sequence(attribute) do |n|
          COUNTRIES[(n % COUNTRIES.size) - 1][attribute]
        end
      end
    end

    %i(name code flag).each do |attribute|
      send attribute, COUNTRIES.first[attribute]
    end
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  code       :string
#  flag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
