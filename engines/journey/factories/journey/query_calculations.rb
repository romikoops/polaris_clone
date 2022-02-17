# frozen_string_literal: true

FactoryBot.define do
  factory :journey_query_calculation, class: "Journey::QueryCalculation" do
    association :query, factory: :journey_query
    status { "completed" }
    pre_carriage { false }
    on_carriage { false }

    trait :door_door do
      pre_carriage { true }
      on_carriage { true }
    end

    trait :port_port do
      pre_carriage { false }
      on_carriage { false }
    end

    trait :door_port do
      pre_carriage { true }
      on_carriage { false }
    end

    trait :port_door do
      pre_carriage { false }
      on_carriage { true }
    end

    trait :completed do
      status { "completed" }
    end

    trait :running do
      status { "running" }
    end

    trait :queued do
      status { "queued" }
    end
  end
end
