# frozen_string_literal: true

FactoryBot.define do
  factory :max_dimensions_bundle do
    association :organization, factory: :organizations_organization
    mode_of_transport { "general" }
    cargo_class { "lcl" }
    aggregate { false }
    width { "500" }
    length { "500" }
    height { "500" }
    payload_in_kg { "10_000" }
    chargeable_weight { "10_000" }
  end
end
