# frozen_string_literal: true

FactoryBot.define do
  factory :country do
    name { 'Sweden' }
    code { 'SE' }
    flag { 'https://restcountries.eu/data/swe.svg' }

    to_create do |instance|
      instance.attributes = Country.create_with(code: instance.code)
        .find_or_create_by(
          name: instance.name
        )
        .attributes
      instance.reload
    end
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
