# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_destination do
    trait :zipcode do
      zipcode { '15211' }
    end

    trait :with_location do
      association :location
    end

    trait :distance do
      distance { 172 }
    end

    trait :zipcode_sequence do
      sequence(:zipcode) do |n|
        (15_000 + n - 1).to_s
      end
    end

    trait :zipcode_broken_sequence do
      sequence(:zipcode) do |n|
        gap = n > 40 ? 10 : 0
        (15_000 + n - 1 + gap).to_s
      end
    end

    country_code { 'SE' }
  end
end

# == Schema Information
#
# Table name: trucking_destinations
#
#  id           :bigint           not null, primary key
#  city_name    :string
#  country_code :string
#  distance     :integer
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :integer
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_destinations_on_city_name     (city_name)
#  index_trucking_destinations_on_country_code  (country_code)
#  index_trucking_destinations_on_distance      (distance)
#  index_trucking_destinations_on_sandbox_id    (sandbox_id)
#  index_trucking_destinations_on_zipcode       (zipcode)
#
