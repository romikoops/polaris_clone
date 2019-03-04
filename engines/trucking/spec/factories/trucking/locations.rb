# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_location, class: 'Trucking::Location' do
    trait :zipcode do
      zipcode { '15211' }
    end

    trait :with_location do
      association :location, factory: :swedish_location
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
      gap = 0
      sequence(:zipcode) do |n|
        gap += n % 40 == 0 ? 100 : 0
        (15_000 + (n - 1 + gap)).to_s
      end
    end

    country_code { 'SE' }
  end
end
