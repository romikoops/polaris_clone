# frozen_string_literal: true

FactoryBot.define do
  factory :country do
    name { 'Sweden' }
    code { 'SE' }
    flag { 'https://restcountries.eu/data/swe.svg' }
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  name       :string
#  code       :string
#  flag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
