# frozen_string_literal: true

FactoryBot.define do
  factory :journey_route_section, class: "Journey::RouteSection" do
    association :from, factory: :journey_route_point
    association :to, factory: :journey_route_point
    association :result, factory: :journey_result
    carrier { "MSC" }
    mode_of_transport { :ocean }
    service { "standard" }
    sequence(:order) { |n| n }
    transit_time { nil }
    transshipment { nil }

    main_carriage

    trait :pre_carriage do
      mode_of_transport { "carriage" }
      order { 1 }
      association :from, factory: :journey_route_point_address
    end

    trait :export do
      mode_of_transport { "relay" }
      order { 2 }
    end

    trait :main_carriage do
      mode_of_transport { "ocean" }
      order { 3 }
    end

    trait :import do
      mode_of_transport { "relay" }
      order { 4 }
    end

    trait :on_carriage do
      mode_of_transport { "carriage" }
      order { 5 }
      association :to, factory: :journey_route_point_address
    end
  end
end
