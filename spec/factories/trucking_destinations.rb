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
#  zipcode      :string
#  country_code :string
#  city_name    :string
#  distance     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :integer
#  sandbox_id   :uuid
#
