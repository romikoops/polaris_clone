# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_location, class: "Trucking::Location" do
    country { factory_country_from_code(code: "SE") }
    data { "15211" }
    query { "postal_code" }
    identifier { "postal_code" }

    trait :zipcode do
      query { "postal_code" }
      identifier { "postal_code" }
      data { "15211" }
    end

    trait :with_location do
      query { "location" }
      identifier { "city" }
      data { "Gothenburg" }
      association :location, factory: :swedish_location
    end

    trait :with_chinese_location do
      query { "location" }
      identifier { "city" }
      data { "Shanghai" }
      association :location, factory: :chinese_location
    end

    trait :distance do
      query { "distance" }
      identifier { "distance" }
      data { 55 }
    end

    trait :zipcode_sequence do
      sequence(:zipcode) do |n|
        (15_000 + n - 1).to_s
      end
    end

    trait :zipcode_broken_sequence do
      gap = 0
      sequence(:zipcode) do |n|
        gap += (n % 40).zero? ? 100 : 0
        (15_000 + (n - 1 + gap)).to_s
      end
    end

    trait :postal_code do
      identifier { "postal_code" }
      query { "postal_code" }
    end

    trait :postal_code_location do
      identifier { "postal_code" }
      query { "location" }
      association :location, factory: :swedish_location
    end

    trait :locode_location do
      identifier { "locode" }
      query { "location" }
      data { "SEGOT" }
      association :location, factory: :xl_swedish_location
    end

    factory :city_location, traits: [:with_location]
    factory :chinese_trucking_location, traits: [:with_chinese_location]
    factory :zipcode_location, traits: %i[postal_code zipcode_sequence]
  end
end

# == Schema Information
#
# Table name: trucking_locations
#
#  id           :uuid             not null, primary key
#  city_name    :string
#  country_code :string
#  distance     :integer
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :uuid
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_locations_on_city_name     (city_name)
#  index_trucking_locations_on_country_code  (country_code)
#  index_trucking_locations_on_distance      (distance)
#  index_trucking_locations_on_location_id   (location_id)
#  index_trucking_locations_on_sandbox_id    (sandbox_id)
#  index_trucking_locations_on_zipcode       (zipcode)
#
