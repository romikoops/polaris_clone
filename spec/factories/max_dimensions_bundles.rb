# frozen_string_literal: true

FactoryBot.define do
  factory :max_dimensions_bundle do
    association :tenant
    mode_of_transport "general"
    aggregate false
    dimension_x "500"
    dimension_y "500"
    dimension_z "500"
    payload_in_kg "10_000"
    chargeable_weight "10_000"
  end
end
