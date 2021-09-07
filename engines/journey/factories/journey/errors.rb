# frozen_string_literal: true

FactoryBot.define do
  factory :journey_error, class: "Journey::Error" do
    association :result_set, factory: :journey_result_set
    association :cargo_unit, factory: :journey_cargo_unit
    association :query, factory: :journey_query
    code { "1001" }
    service { "Standard" }
    carrier { "MSC" }
    mode_of_transport { "ocean" }
    property { "Weight" }
    value { "1100" }
    limit { "1000" }
  end
end
